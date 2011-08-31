# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruport}
  s.version = "1.6.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gregory Brown", "Mike Milner", "Andrew France"]
  s.date = %q{2009-12-12}
  s.description = %q{      Ruby Reports is a software library that aims to make the task of reporting
      less tedious and painful. It provides tools for data acquisition,
      database interaction, formatting, and parsing/munging.
}
  s.email = %q{gregory.t.brown@gmail.com}
  s.files = ["test/template_test.rb", "test/record_test.rb", "test/csv_formatter_test.rb", "test/data_feeder_test.rb", "test/table_pivot_test.rb", "test/helpers.rb", "test/table_test.rb", "test/text_formatter_test.rb", "test/html_formatter_test.rb", "test/grouping_test.rb", "test/controller_test.rb", "test/pdf_formatter_test.rb", "examples/centered_pdf_text_box.rb", "examples/line_plotter.rb", "examples/btree/commaleon/commaleon.rb", "examples/anon.rb", "examples/pdf_report_with_common_base.rb", "examples/row_renderer.rb", "examples/tattle_ruby_version.rb", "examples/simple_pdf_lines.rb", "examples/png_embed.rb", "examples/trac_ticket_status.rb", "examples/tattle_rubygems_version.rb", "examples/simple_templating_example.rb"]
  s.homepage = %q{http://rubyreports.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruport}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A generalized Ruby report generation and templating engine.}
  s.test_files = ["test/template_test.rb", "test/record_test.rb", "test/csv_formatter_test.rb", "test/data_feeder_test.rb", "test/table_pivot_test.rb", "test/helpers.rb", "test/table_test.rb", "test/text_formatter_test.rb", "test/html_formatter_test.rb", "test/grouping_test.rb", "test/controller_test.rb", "test/pdf_formatter_test.rb", "examples/centered_pdf_text_box.rb", "examples/line_plotter.rb", "examples/btree/commaleon/commaleon.rb", "examples/anon.rb", "examples/pdf_report_with_common_base.rb", "examples/row_renderer.rb", "examples/tattle_ruby_version.rb", "examples/simple_pdf_lines.rb", "examples/png_embed.rb", "examples/trac_ticket_status.rb", "examples/tattle_rubygems_version.rb", "examples/simple_templating_example.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fastercsv>, [">= 0"])
      s.add_runtime_dependency(%q<pdf-writer>, ["= 1.1.8"])
    else
      s.add_dependency(%q<fastercsv>, [">= 0"])
      s.add_dependency(%q<pdf-writer>, ["= 1.1.8"])
    end
  else
    s.add_dependency(%q<fastercsv>, [">= 0"])
    s.add_dependency(%q<pdf-writer>, ["= 1.1.8"])
  end
end
