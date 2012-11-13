#encoding:utf-8
class SQLArray
  def initialize(sql)
    if sql.is_a?(Hash)
      @array = [sql, "AND", nil]
    elsif sql.is_a?(Array)
      @array = sql
    end
  end

  def to_s
    if @array[2]==nil
      @array[0]
    else
      if @array[0].blank?
        @array[2]
      else
        ["(", @array.join(" "), ")"].join
      end
    end
  end

  def to_sql(record=nil)
    if @array[2]==nil
      @array[0].to_sql(record)
    else
      sql_array = SQLArrayParam.new
      left_side, right_side = [@array[0].to_sql(record), @array[2].to_sql(record)]
      sql_array.merge!(left_side, right_side, @array[1])
      return sql_array.to_a
    end
  end

  def +(h)
    if h.is_a?(Hash)
      return SQLArray.new([self, "AND", h])
    elsif h.is_a?(SQLArray)
      return SQLArray.new([self, "AND", h])
    end
  end

  def -(h)
    if h.is_a?(Hash)
      return SQLArray.new([self, "OR", h])
    elsif h.is_a?(SQLArray)
      return SQLArray.new([self, "OR", h])
    end
  end
end

class SQLArrayParam
  def initialize(param = nil)
    @param_ary ||= ["", {}]
    @param_ary = param.to_a if param
  end

  def to_a
    @param_ary
  end

  def sql
    @param_ary[0]
  end

  def sql=(value)
    @param_ary[0]=value
  end

  def sql_params
    @param_ary[1]
  end

  def sql_params=(value)
    @param_ary[1]=value
  end

  def add(param, connector = "AND")
    data = pre_add(param)
    self.sql+=((self.sql.blank? ? "" : " #{connector} ") + data.sql)
    self.sql_params.merge!(data.sql_params)
    return self
  end

  def pre_add(param)
    param = SQLArrayParam.new(param) if param.is_a?(Array)
    new_sql = param.sql
    new_param = {}
    param.sql_params.each do |key, value|
      new_key = valid_key(key)
      if new_key!=key
        new_sql.gsub!(Regexp.new(":#{key}\\b"), ":#{new_key}")
      end
      new_param.merge!({new_key=>value})
    end
    return SQLArrayParam.new([new_sql, new_param])
  end

  def merge!(param, param1, connector = "AND")
    param = SQLArrayParam.new(param) if param.is_a?(Array)
    param1 = SQLArrayParam.new(param1) if param1.is_a?(Array)
    data = pre_add(param)
    self.sql_params.merge!(data.sql_params)
    data1 = pre_add(param1)
    self.sql_params.merge!(data1.sql_params)
    if data.sql.blank?
      self.sql += data1.sql
    else
      self.sql += ["(", data.sql, " #{connector} ", data1.sql, ")"].join
    end

    return true
  end

  def valid_key(key, i=0)
    if self.sql_params.keys.include?(key)
      return valid_key("#{key}_#{i}".to_sym, i+1)
    else
      return key
    end
  end
end

class Hash

  def +(h)
    return SQLArray.new([self, "AND", h])
  end

  def -(h)
    return SQLArray.new([self, "OR", h])
  end

  def delete_blank!
    self.delete_if{|key, value| value.blank?}
  end

  def to_s
    return self.inspect
  end

  def to_sql(record=nil)
    sql_with_params = []
    self.each do |key, value|
      if record
        sql_p = record.get_sql_by_key_value(key, value)
        sql_with_params << sql_p if sql_p
      else
        sql_with_params << ["#{key} = #{value}", {}]
      end
    end
    sql_array = SQLArrayParam.new
    sql_with_params.each do |sp|
      sql_array.add(sp)
    end
    if sql_with_params.size>1
      sql = ["(", sql_array.sql, ")"].join
    else
      sql = sql_array.sql
    end
    return [sql, sql_array.sql_params]
  end
end

module SqlLogic
  def get_sql(sql_array)
    sql_array = SQLArray.new(sql_array) if sql_array.is_a?(Hash)
    raise ArgumentError.new("Argument Error!") unless sql_array.is_a?(SQLArray)

    return sql_array.to_sql(self)
  end

  def get_sql_by_hash(sql_hash, options={})
    options[:skip_blank]||=true
    options[:strip]||=true
    raise ArgumentError.new("Argument Error!") unless sql_hash.is_a?(Hash)
    if options[:skip_blank]
      sql_hash.each{|k,v| v.delete_if{|i| i.blank?} if v&&v.is_a?(Array)}
      sql_hash.delete_if{|key, value| value.blank?}
    end
    sql_hash.each{|key, value| sql_hash[key] = value.strip if value.respond_to?(:strip)} if options[:strip]
    get_sql(sql_hash)
  end

  def table_name_without_schema
    self.table_name.include?(".") ? self.table_name.split(".").last : self.table_name
  end

  def get_sql_by_key_value(key, value)
    #key_method = "#{key}".to_sym
    associations = reflect_on_all_associations.collect { |assoc| assoc.name }
    if key.to_s =~ /^(#{column_names.join("|")})_(#{Conditions::PRIMARY_CONDITIONS.join("|")})$/ or key.to_s =~ /^(#{associations.join("|")})_(\w+)_(#{Conditions::PRIMARY_CONDITIONS.join("|")})$/
      key_method = "#{key}_to_sql".to_sym
      return self.send(key_method, value)
      #if self.respond_to?(key_method)
      sql = "#{self.table_name_without_schema}.#{key} = :#{key} "
      return [sql, {key_method=>value}]
      #return self.send(key_method, value)
      #else
      #  raise ArgumentError.new("Cannnot find #{key} method!")
      #end
    else
      return nil
    end
  end

  module Conditions
    COMPARISON_CONDITIONS = {
            :equals => [:is, :eq],
            :eq => [],
            :does_not_equal => [:not_equal_to, :is_not, :not, :neq],
            :neq => [],
            :less_than => [:lt, :before],
            :lt => [], :lte=>[],
            :less_than_or_equal_to => [:lte],
            :greater_than => [:gt, :after],
            :gt=>[], :gte=>[],
            :in=>[], :not_in=>[],
            :greater_than_or_equal_to => [:gte],
            }

    WILDCARD_CONDITIONS = {
            :like => [:contains, :includes],
            :begins_with => [:bw],
            :ends_with => [:ew],
            :full_text=> []
            }

    BOOLEAN_CONDITIONS = {
            :null => [:nil],
            :not_null => [],
            :empty => []
    }

    CONDITIONS = {}

    COMPARISON_CONDITIONS.merge(WILDCARD_CONDITIONS).each do |condition, aliases|
      CONDITIONS[condition] = aliases
    end

    BOOLEAN_CONDITIONS.each { |condition, aliases| CONDITIONS[condition] = aliases }

    PRIMARY_CONDITIONS = CONDITIONS.keys
    ALIAS_CONDITIONS = CONDITIONS.values.flatten

    # Returns the primary condition for the given alias. Ex:
    #
    #   primary_condition(:gt) => :greater_than
    def primary_condition(alias_condition)
      CONDITIONS.find { |k, v| k == alias_condition.to_sym || v.include?(alias_condition.to_sym) }.first
    end

    def primary_condition_name(name)
      if primary_condition?(name)

        name.to_sym
      elsif details = alias_condition_details(name)
        "#{details[:column]}_#{primary_condition(details[:condition])}".to_sym
      else
        nil
      end
    end

    def primary_condition?(name)
      !primary_condition_details(name).nil?
    end

    private
    def method_missing(name, *args, &block)
      if details = primary_condition_details(name)
        get_sql_and_params(details[:column], details[:condition], args)
      else
        super
      end
    end

    def primary_condition_details(name)
      if name.to_s =~ /^(#{column_names.join("|")})_(#{PRIMARY_CONDITIONS.join("|")})_to_sql$/
        {:column => $1, :condition => $2}
      end
    end

    def get_sql_and_params(column, condition, args)
      column_type = columns_hash[column.to_s].type
      case condition.to_s
        when /^equals/, /^eq/
          condition_sql(condition, column, column_type, "#{table_name_without_schema}.#{column} = ?", args)
        when /^does_not_equal/, /^noteq/, /^neq/
          condition_sql(condition, column, column_type, "#{table_name_without_schema}.#{column} != ?", args)
        when /^less_than_or_equal_to/, /^lte/
          condition_sql(condition, column, column_type, "#{table_name_without_schema}.#{column} <= ?", args, :lte)
        when /^less_than/, /^lt/
          condition_sql(condition, column, column_type, "#{table_name_without_schema}.#{column} < ?", args, :lt)
        when /^greater_than_or_equal_to/, /^gte/
          condition_sql(condition, column, column_type, "#{table_name_without_schema}.#{column} >= ?", args, :gte)
        when /^greater_than/, /^gt/
          condition_sql(condition, column, column_type, "#{table_name_without_schema}.#{column} > ?", args, :gt)
        when /^like/
          condition_sql(condition, column, column_type, "lower(#{table_name_without_schema}.#{column}) LIKE ?", args, :like)
        when /^begins_with/
          condition_sql(condition, column, column_type, "lower(#{table_name_without_schema}.#{column}) LIKE ?", args, :begins_with)
        when /^ends_with/
          condition_sql(condition, column, column_type, "lower(#{table_name_without_schema}.#{column}) LIKE ?", args, :ends_with)
        when /^in/
          condition_sql(condition, column, column_type, "#{table_name_without_schema}.#{column} IN (?)", args)
        when /^not_in/
          condition_sql(condition, column, column_type, "#{table_name_without_schema}.#{column} NOT IN (?)", args)
        when /^full_text/
          condition_sql(condition, column, column_type, "CONTAINS(#{table_name_without_schema}.#{column}, ?) > 0", args)
        when "null"
          return ["#{table_name_without_schema}.#{column} IS NULL", {}]
        when "not_null"
          return ["#{table_name_without_schema}.#{column} IS NOT NULL", {}]
        when "empty"
          return ["#{table_name_without_schema}.#{column} = ''", {}]
      end
    end

    def condition_sql(condition, column, column_type, sql, args, value_modifier = nil)
      case condition.to_s
        when /_(any|all)$/
          #TODO
          values = args
          return ["", {}] if values.empty?
          values = values.flatten

          values_to_sub = nil
          if value_modifier.nil?
            values_to_sub = values
          else
            values_to_sub = values.collect { |value| value_with_modifier(value, value_modifier, column_type) }
          end

          join = $1 == "any" ? " OR " : " AND "
          _sql = [values.collect { |value| sql }.join(join), *values_to_sub]
        else
          value = args[0]
          column_symbol = column_key_symbol(column)
          _sql = sql.gsub("?", column_symbol_in_sql(column_symbol, column_type))
          return [_sql, {column_symbol.to_sym=>value_with_modifier(value, value_modifier, column_type)}]
      end
    end

    def column_key_symbol(column)
      [self.table_name_without_schema, column].join("_")
    end

    def column_symbol_in_sql(column, column_type)
      return ":#{column}"
      case column_type
        when :datetime
          "to_date1(:#{column})"
        else
          ":#{column}"
      end
    end

    def value_with_modifier(value, modifier, column_type)
      case column_type
        when :datetime
          if [:gt, :gte].include?(modifier)
            return fill_date(value, '00:00:00')
          elsif [:lt, :lte].include?(modifier)
            return fill_date(value, '23:59:59')
          end
      end
      case modifier
        when :like
          "%#{value.downcase}%"
        when :begins_with
          "#{value.downcase}%"
        when :ends_with
          "%#{value.downcase}"
        else
          value
      end
    end

    def fill_date(date, time)
      if date.is_a?(String)
        if date.size==10
          new_date = Time.parse([date, time].join(" "))
          return new_date.label
        else
          new_date = Time.parse(date)
          return new_date.label
        end
      elsif date.is_a?(Time)
        return date.label
      else
        return date.to_s
      end
    end
  end

  module Associations

    def primary_condition_name(name) # :nodoc:
      if result = super
        result
      elsif association_condition?(name)
        name.to_sym
      elsif details = association_alias_condition_details(name)
        "#{details[:association]}_#{details[:column]}_#{primary_condition(details[:condition])}".to_sym
      else
        nil
      end
    end

    # Is the name of the method a valid name for an association condition?
    def association_condition?(name)
      !association_condition_details(name).nil?
    end

    # Is the ane of the method a valie name for an association alias condition?
    # An alias being "gt" for "greater_than", etc.
    def association_alias_condition?(name)
      !association_alias_condition_details(name).nil?
    end

    private
    def method_missing(name, *args, &block)
      if details = association_condition_details(name)
        create_association_condition(details[:association], details[:column], details[:condition], args)
      else
        super
      end
    end

    def association_condition_details(name)
      associations = reflect_on_all_associations.collect { |assoc| assoc.name }
      if name.to_s =~ /^(#{associations.join("|")})_(\w+)_(#{Conditions::PRIMARY_CONDITIONS.join("|")})_to_sql$/
        {:association => $1, :column => $2, :condition => $3}
      end
    end

    def create_association_condition(association_name, column, condition, args)
      #named_scope("#{association_name}_#{column}_#{condition}", association_condition_options(association_name, "#{column}_#{condition}", args))
      values = args
      association = reflect_on_association(association_name.to_sym)
      association_method = "#{column}_#{condition}_to_sql"
      result = association.klass.send(association_method, *args)
    end
  end
end

ActiveRecord::Base.extend(SqlLogic)
ActiveRecord::Base.extend(SqlLogic::Associations)
ActiveRecord::Base.extend(SqlLogic::Conditions)
