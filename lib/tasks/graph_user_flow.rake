namespace :report do
  task :user_flow => :environment do
    require 'gratr/import'
    require 'gratr/dot'

    def visit_path(visit)
      visit.controller + "/" + visit.action
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
          AND created_at > '06/01/2011'
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

    landing_page_visits.each do |visit|
      dg.add_vertex!(visit_path(visit)) unless dg.vertex?(visit_path(visit))

      if prev_visit
        first_point = visit_path(visit)
        second_point = visit_path(prev_visit)

        if dg.edge?(first_point, second_point)
          dg.edges.each do |edge|
            if edge.eql?(GRATR::Arc.new(first_point, second_point))
              label = edge.label[:label]
              edge.label[:label] = label + 1
            end
          end
        else
          dg.add_edge!(first_point, second_point, :label => 1)
        end
      end

      prev_visit = visit
    end

    dg.write_to_graphic_file('png','visualize')
  end
end
