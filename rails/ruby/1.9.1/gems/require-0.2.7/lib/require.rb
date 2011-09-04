require 'rubygems'
require "#{File.dirname(__FILE__)}/require/dsl"
require "#{File.dirname(__FILE__)}/require/gemspec"

class Require
  
  @dsl = {}
  @gemspec = {}
  
  class <<self
  
    def all(*args)
      dsl.all *args
    end
  
    def call(force_root=nil, &block)
      dsl(force_root).call &block
    end
    
    def dsl(force_root=nil)
      @dsl[root(force_root)] ||= Dsl.new
    end
  
    def get(*args)
      dsl.get *args
    end
  
    def gemspec
      (@gemspec[root] ||= Gemspec.new).instance
    end
  
    def name
      (@gemspec[root] ||= Gemspec.new).name
    end
  
    def method_missing(method, value=nil, options=nil)
      method = method.to_s
      if method.include?('!')
        method = method.gsub!('!', '').intern
        gem = get(:gem, method)
        profile = get(method)
        if profile
          profile.dsl.each do |dsl|
            if dsl.gem?
              require_gem! dsl.name, dsl.version, dsl.dsl
            elsif dsl.load_path?
              load_path! dsl.path
            elsif dsl.require?
              require! dsl.path
            end
          end
        elsif gem
          require_gem! gem.name
        end
      else
        raise "Require##{method} does not exist"
      end
    end
    
    def require!(paths)
      return unless paths
      [ paths ].flatten.each do |path|
        path_with_root = "#{root}/#{path}"
        if file_exists?(path_with_root)
          Kernel.require path_with_root
        else
          Kernel.require path
        end
      end
    end
  
    def reset(&block)
      @dsl = {}
      call caller[0], &block
    end
  
    def root(force=nil)
      if force
        return clean_caller(force)
      else
        roots = @dsl.keys.sort { |a,b| b.length <=> a.length }
        root = roots.detect do |r|
          caller.detect do |c|
            clean_caller(c)[0..r.length-1] == r
          end
        end
        if root
          root
        elsif defined?(::Rake)
          Rake.original_dir
        else
          raise("You have not executed a Require block (Require not configured)")
        end
      end
    end
  
    private
    
    def clean_caller(string)
      File.dirname(File.expand_path(string.split(':').first))
    end
  
    def dir_exists?(path)
      File.exists?(path) && File.directory?(path)
    end
  
    def file_exists?(path)
      (File.exists?(path) && File.file?(path)) ||
      (File.exists?("#{path}.rb") && File.file?("#{path}.rb"))
    end
  
    def load_path!(paths)
      return unless paths
      [ paths ].flatten.each do |path|
        path_with_root = "#{root}/#{path}"
        if root && dir_exists?(path_with_root)
          $: << path_with_root
        else
          $: << path
        end
      end
    end
  
    def require_gem!(name, overwrite_version=nil, overwrite_dsl=nil)
      gem = get(:gem, name)
      if gem
        begin
          if overwrite_version || gem.version
            Kernel.send :gem, name.to_s, overwrite_version || gem.version
          else
            Kernel.send :gem, name.to_s
          end
          if overwrite_dsl || gem.dsl
            (overwrite_dsl || gem.dsl).all(:require).each do |dsl|
              require! dsl.path
            end
          end
        rescue Exception => e
          if overwrite_version || gem.version
            $stdout.puts "Gem #{name} (#{overwrite_version || gem.version}) could not be activated"
          else
            $stdout.puts "Gem #{name} could not be activated"
          end
        end
      end
    end
  end
end

def Require(&block)
  Require.call caller[0], &block
end
