class Require
  module Tasks
    
    def self.set(*types)
      if types.include?(:ask_docs)
        $stdout.puts "Generate documentation?"
        @@gen_docs = $stdin.gets.downcase[0..0] == 'y'
      elsif types.include?(:docs)
        @@gen_docs = true
      elsif types.include?(:no_docs)
        @@gen_docs = false
      end
      if types.include?(:ask_sudo)
        $stdout.puts "Use sudo?"
        @@use_sudo = $stdin.gets.downcase[0..0] == 'y'
      elsif types.include?(:sudo)
        @@use_sudo = true
      elsif types.include?(:no_sudo)
        @@use_sudo = false
      end
    end
    
    def self.rm_pkg
      cmd = "rm -Rf pkg"
      $stdout.puts cmd
      system cmd
    end
    
    def self.run(cmd)
      cmd = "#{'sudo ' if @@use_sudo}#{cmd}#{' --no-ri --no-rdoc' unless @@gen_docs}"
      $stdout.puts cmd
      system cmd
    end
    
    def self.install_gem(name, version = nil)
      unless has_gem?(name, version)
        run "gem install #{name}#{" -v '#{version}'" if version}"
      end
    end
    
    def self.has_gem?(name, version=nil)
      if !$GEM_LIST
        gems = {}
        `gem list --local`.each_line do |line|
          gems[$1.to_sym] = $2.split(/, /) if line =~ /^(.*) \(([^\)]*)\)$/
        end
        $GEM_LIST = gems
      end
      if $GEM_LIST[name.to_sym]
        if version
          version = version.gsub("=",'')
          if $GEM_LIST[name.to_sym].include?(version) 
            $stdout.puts "Gem: #{name}:#{version} already installed, skipping"
            return true
          end  
        else
          $stdout.puts "Gem: #{name} already installed, skipping"
          return true
        end
      end
      false
    end
  end
end

namespace :gem do
  desc "Install gem"
  task :install do
    Require::Tasks.rm_pkg
    Rake::Task['gem'].invoke
    Require::Tasks.set :docs, :ask_sudo
    Require::Tasks.run "gem uninstall #{Require.name} -x"
    Require::Tasks.run "gem install pkg/#{Require.name}*.gem"
    Require::Tasks.rm_pkg
  end
  
  desc "Push gem"
  task :push do
    Require::Tasks.rm_pkg
    Rake::Task['gem'].invoke
    Require::Tasks.set :docs, :no_sudo
    Require::Tasks.run "gem push pkg/#{Require.name}*.gem"
    Require::Tasks.rm_pkg
  end
end

desc "List gem dependencies"
task :gems do
  Require.all(:gem).sort { |a,b| a.name.to_s <=> b.name.to_s }.each do |dsl|
    puts "#{dsl.name} (#{dsl.version})"
  end
end

namespace :gems do
  desc "Install gem dependencies, use DOCS=1|0, SUDO=1|0 to bypass prompts"
  task :install do
    doc_me = ENV['DOCS'].nil? ? :ask_docs : (ENV['DOCS'] == "1" ? :docs : :no_docs)
    sudo_me = ENV['SUDO'].nil? ? :ask_sudo : (ENV['SUDO'] == "1" ? :sudo : :no_sudo)
    Require::Tasks.set doc_me, sudo_me
    Require.all(:gem).sort { |a,b| a.name.to_s <=> b.name.to_s }.each do |dsl|
      Require::Tasks.install_gem dsl.name, dsl.version
    end
  end
end

if defined?(Rake::GemPackageTask)
  desc "Package gem"
  Rake::GemPackageTask.new(Require.gemspec) do |pkg|
    pkg.gem_spec = Require.gemspec
  end
end

if defined?(Spec::Rake::SpecTask)
  desc "Run specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ["--format", "specdoc", "--colour"]
    t.spec_files = Dir["#{Require.root}/spec/**/*_spec.rb"]
  end
end