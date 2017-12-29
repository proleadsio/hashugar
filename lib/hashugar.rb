require "hashugar/version"

class Hashugar
  attr_reader :table
  attr_reader :table_with_original_keys
  
  def initialize(hash)
    @table = {}
    @table_with_original_keys = {}
    hash.each_pair do |key, value|
      hashugar = value.to_hashugar
      @table_with_original_keys[key] = hashugar
      @table[stringify(key)] = hashugar
    end
  end

  def method_missing(method, *args, &block)
    method = method.to_s
    if method.chomp!('=')
      @table[method] = args.first
    else
      @table[method]
    end
  end

  def [](key)
    @table[stringify(key)]
  end

  def []=(key, value)
    @table[stringify(key)] = value
  end

  def respond_to?(key, include_all=false)
    super(key) || @table.has_key?(stringify(key))
  end

  def each(&block)
    @table_with_original_keys.each(&block)
  end

  def to_hash
    hash = @table_with_original_keys.to_hash
    hash.each do |key, value|
      hash[key] = value.to_hash if value.is_a?(Hashugar)
    end
  end

  def to_hashugar_hash
    hash = @table_with_original_keys.to_hash
    hash.each do |key, value|
      hash[key] = value.to_hash if value.is_a?(Hashugar)
    end
  end

  def collect(&block)
    @table_with_original_keys.collect(&block)
  end
  
  def select(&block)
    @table_with_original_keys.select(&block)
  end

  def reject(&block)
    @table_with_original_keys.reject(&block)
  end
  
  def any?(&block)
    @table_with_original_keys.any?(&block)
  end
  
  def keys
    @table_with_original_keys.keys
  end

  def values
    @table_with_original_keys.values
  end
  
  def length
    @table_with_original_keys.length
  end
  
  def invert
    @table_with_original_keys.invert
  end

  def empty?
    @table.empty?
  end

  private
  def stringify(key)
    key.is_a?(Symbol) ? key.to_s : key
  end
end

class Hash
  def to_hashugar
    Hashugar.new(self)
  end

  def to_hashugar_hash
    Hashugar.new(self).to_hashugar_hash
  end
end

class Array
  def to_hashugar
    map(&:to_hashugar)
  end

  def to_hashugar_hash
    Array.new(collect(&:to_hashugar_hash))
  end
end

class Object
  def to_hashugar
    self
  end

  def to_hashugar_hash
    self
  end
end
