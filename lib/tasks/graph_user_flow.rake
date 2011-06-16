namespace :report do
  task :user_flow => :environment do
    require 'gratr/import'
    require 'gratr/dot'

    def increment_label(edge)
      label = edge.label[:label]
      edge.label[:label] = label + 1
    end

    dg = Digraph.new
    prev_visit = nil

    landing_page_visits = Visit.find_by_sql(<<-eos
      SELECT v.session_id, v.controller, v.action, v.created_at
      FROM (
        SELECT session_id, created_at
        FROM visits
        WHERE controller = 'projects'
          AND action = 'info'
          AND user_id IS NULL
          AND created_at > '06/10/2011'
        ) AS x
      INNER JOIN visits as v
        ON x.session_id = v.session_id
        AND v.created_at >= x.created_at
      WHERE v.controller IN ('projects', 'users', 'subscriptions')
        AND v.action IN ('info', 'ide', 'create', 'subscribe', 'register_subscribe', 'thanks')
      GROUP BY v.session_id, v.controller, v.action, v.created_at
      ORDER BY v.session_id, v.created_at
      eos
    )

    landing_page_visits = landing_page_visits.map do |visit|
      { :session_id => visit["session_id"], :path => visit["controller"] + '/' + visit["action"] }
    end

    landing_page_visits.uniq!

    session_ids = landing_page_visits.map do |visit|
      visit[:session_id]
    end

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
        else
          dg.add_edge!("Start", visit[:path], :label => session_ids.uniq.count)

          if dg.edge?(prev_path, 'End')
            dg.edges.each do |edge|
              if edge.eql?(GRATR::Arc.new(prev_path, 'End'))
                increment_label(edge)
              end
            end
          else
            dg.add_edge!(prev_path, 'End', :label => 1)
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
        end
      end
    else
      dg.add_edge!(last_path, 'End', :label => 1)
    end

    dg.write_to_graphic_file('png','visualize')
  end
end
