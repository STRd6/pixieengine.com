namespace :report do
  task :send => [:user_flow, :user_retention] do
    Notifier.analytics(User.find(4)).deliver
    Notifier.analytics(User.find(1)).deliver

    graph_png = File.join(Rails.root, 'graph.png')
    graph_dot = File.join(Rails.root, 'graph.dot')
    report_html = File.join(Rails.root, 'report.html')

    File.delete(graph_png) if File.exist?(graph_png)
    File.delete(graph_dot) if File.exist?(graph_dot)
    File.delete(report_html) if File.exist?(report_html)
  end

  task :user_flow => :environment do
    require 'gratr/dot'

    def increment_label(edge)
      label = edge.label[:label]
      edge.label[:label] = label + 1
    end

    dg = GRATR::Digraph.new
    prev_visit = nil

    week_start = (Date.today.beginning_of_week - 1).to_s

    landing_page_visits = Visit.find_by_sql <<-eos
      SELECT v.session_id, v.controller, v.action, v.created_at
      FROM (
        SELECT session_id, created_at
        FROM visits
        WHERE controller = 'projects'
          AND action = 'info'
          AND user_id IS NULL
          AND created_at >= '#{week_start}'
        ) AS x
      INNER JOIN visits as v
        ON x.session_id = v.session_id
        AND v.created_at >= x.created_at
      WHERE v.controller IN ('projects', 'users', 'subscriptions')
        AND v.action IN ('info', 'ide', 'create', 'subscribe', 'register_subscribe', 'thanks')
      GROUP BY v.session_id, v.controller, v.action, v.created_at
      ORDER BY v.session_id, v.created_at
      eos

    landing_page_visits = landing_page_visits.map do |visit|
      { :session_id => visit["session_id"], :path => visit["controller"] + '/' + visit["action"] }
    end

    landing_page_visits.uniq!

    session_ids = landing_page_visits.map do |visit|
      visit[:session_id]
    end

    vertex_counts = {}

    landing_page_visits.each do |visit|
      if prev_visit
        current_path = visit[:path]
        prev_path = prev_visit[:path]
        if prev_visit[:session_id] == visit[:session_id]
          if dg.edge?(prev_path, current_path)
            dg.edges.each do |edge|
              if edge.eql?(GRATR::Arc.new(prev_path, current_path))
                increment_label(edge)
              end
            end
          else
            dg.add_edge!(prev_path, current_path, :label => 1)
          end
          vertex_counts[current_path] = (vertex_counts[current_path] || 0) + 1
        else
          dg.add_edge!("Start", visit[:path], :label => session_ids.uniq.count)
          vertex_counts["Start"] = session_ids.uniq.count
          vertex_counts[visit[:path]] = session_ids.uniq.count

          if dg.edge?(prev_path, 'End')
            dg.edges.each do |edge|
              if edge.eql?(GRATR::Arc.new(prev_path, 'End'))
                increment_label(edge)
                vertex_counts['End'] = (vertex_counts['End'] || 0) + 1
              end
            end
          else
            dg.add_edge!(prev_path, 'End', :label => 1)
            vertex_counts['End'] = (vertex_counts['End'] || 0) + 1
          end
        end
      end

      prev_visit = visit
    end

    # hack to fix off by one error
    last_index = landing_page_visits.count - 1
    last_path = landing_page_visits[last_index][:path]

    if dg.edge?(last_path, 'End')
      dg.edges.each do |edge|
        if edge.eql?(GRATR::Arc.new(last_path, 'End'))
          increment_label(edge)
          vertex_counts['End'] = (vertex_counts['End'] || 0) + 1
        end
      end
    else
      dg.add_edge!(last_path, 'End', :label => 1)
      vertex_counts['End'] = (vertex_counts['End'] || 0) + 1
    end

    #calculate percentages
    dg.edges.each do |edge|
      label = edge.label[:label]
      edge.label[:label] = "#{label} (#{((label / vertex_counts[edge[0]].to_f) * 100).round}%)"
    end

    dg.write_to_graphic_file
  end

  task :user_retention => :environment do
    include Ruport::Data

    created = User.find_by_sql <<-eos
      SELECT to_char(created_at, 'FMmonth') AS month, date_part('month', created_at) AS month_number, id
      FROM users
      GROUP BY to_char(created_at, 'FMmonth'), date_part('month', created_at), id
      ORDER BY month
    eos


    last_request_by_month = User.find_by_sql <<-eos
      SELECT to_char(last_request_at, 'FMmonth') AS month, date_part('month', last_request_at) AS month_number, id
      FROM users
      WHERE date_part('year', last_request_at) = 2011
      GROUP BY to_char(last_request_at, 'FMmonth'), date_part('month', last_request_at), id
      ORDER BY month
    eos

    start_date = Date.new 2011, 1, 1
    end_date = Date.new 2011, 12, 31

    months = ((start_date..end_date).select { |d| d.day == 1 }).map { |d| d.strftime('%B').to_s.downcase }

    month_lookup = {
      'january' => 1,
      'february' => 2,
      'march' => 3,
      'april' => 4,
      'may' => 5,
      'june' => 6,
      'july' => 7,
      'august' => 8,
      'september' => 9,
      'october' => 10,
      'november' => 11,
      'december' => 12
    }

    created_per_month = {}
    output = {}

    months.each do |month|
      created_per_month[month] = { 'ids' => [], 'total' => 0 }
      output[month] = []
    end

    created.each do |user|
      created_per_month[user['month']]['ids'] << user['id']
      created_per_month[user['month']]['total'] += 1
    end

    last_request_by_month.each do |user|
      current_month = user['month']
      created_month = nil

      months.each do |month|
        if created_per_month[month]['ids'].include?(user['id'])
          created_month = month
        end
      end

      created_month_number = month_lookup[created_month]
      current_month_number = user['month_number'].to_i

      (created_month_number..current_month_number).each do |month_number|
        output[created_month][month_number - 1] = (output[created_month][month_number - 1] || 0) + 1
      end
    end

    table = Table.new
    table.add_columns(%w[months_since 1 2 3 4 5 6 7 8 9 10 11 12], :default => '0')

    months.each do |month|
      output[month].each_with_index do |entry, i|
        unless entry.nil?
          output[month][i] = ((output[month][i] / created_per_month[month]['total'].to_f) * 100).round.to_s + "%"
        end
      end

      output[month].compact!
      table << [month] + output[month]
    end

    table.to_html(:file => 'report.html')
  end

  task :unused_paths => :environment do
    visits = Visit.find_by_sql(<<-eos
      SELECT session_id, controller, action
      FROM visits
      WHERE controller != 'chats'
    eos

    )

    total = visits.count

    visits = visits.map do |visit|
      { :session_id => visit["session_id"], :path => visit["controller"] + '/' + visit["action"] }
    end

    action_counts = {}

    visits.each do |visit|
      action_counts[visit[:path]] = (action_counts[visit[:path]] || 0) + 1
    end

    action_counts = action_counts.sort_by { |k, v| v }

    #calculate percentages
    action_counts.each do |key, value|
      p "#{key}: #{value} (#{((value / total.to_f) * 100).round}%)"
    end
  end

  task :event_funnel => :environment do
    include Ruport::Data

    def subquery(column, amount)
      "SELECT #{column} FROM events GROUP BY #{column} HAVING COUNT(name) > #{amount}"
    end

    user_events = Event.find_by_sql "SELECT COALESCE(CAST(user_id AS varchar), session_id) as person, name, created_at FROM events WHERE user_id IN (#{subquery('user_id', 2)}) OR session_id IN (#{subquery('session_id', 2)}) ORDER BY user, created_at DESC"

    table = Table.new
    table.add_columns(%w[events 1 2 3 4 5 6 7 8 9 10 11 12], :default => '')

    previous_user = nil
    user_actions = []
    output = []

    user_events.each do |event|
      user = event.person

      p event.name

      if !previous_user
        user_actions << "#{event.name} at #{event.created_at}"
      elsif previous_user == user
        user_actions << "#{event.name} at #{event.created_at}"
      else
        output << { :user => previous_user, :events => user_actions }
        user_actions.clear
        user_actions << "#{event.name} at #{event.created_at}"
      end

      previous_user = user
    end

    p output

  end
end
