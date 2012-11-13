#encoding:utf-8
class FileManager

  attr_accessor :root_folder_path, :file_exts, :file_max_size, :file_content_type,
          :file_format_error_message, :folder_type, :file_name, :file_folder

  #folder_type ---- :date  /  :id
  def initialize(args = {})
    self.root_folder_path   = args[:root_folder_path] unless args[:root_folder_path].blank?
    self.file_max_size = args[:file_max_size] unless args[:file_max_size].blank?
    self.file_exts = args[:file_exts]||[]
    self.file_content_type = args[:file_content_type]||[]
    self.file_format_error_message = "文件格式错误！"
    self.folder_type = args[:folder_type]||:date
  end

  def self.expand_path(path)
    folder = "#{File.expand_path(Rails.root)}/#{path}"
    Dir.mkdir(folder) if not File.exist?(folder)
    folder
  end

  def upload_file(file)
    if (self.file_content_type.size>0&&!self.file_content_type.include?(file.content_type.to_s.strip.downcase))
      raise self.file_format_error_message
    end

    if !file.original_filename.empty?
      file_ext = file.original_filename.split(".").last
      unless (self.file_exts.include?(file_ext.downcase))
        raise self.file_format_error_message + "能够接受的文件类型为#{self.file_exts.join(",")}。"
      end
      raise "文件太大，应该不能超过#{self.file_max_size/1024}kb。" if file.size>self.file_max_size
      raise "不能上传空文件。" if file.size<10
      self.file_name = new_file_name(file.original_filename)

      Dir.mkdir(self.file_full_folder) if not File.exist?(self.file_full_folder)

      File.open(self.file_full_path, "wb") do |f|
          f.write(file.read)
      end
      return self.file_name_with_path
    end
  end

  def kill_file(file)
      file_name = self.root_folder_path + "/" + file
      File.delete file_name
  rescue => e
  end

  #文件路径（相对路径）
  def file_name_with_path
    "#{self.file_folder}/#{self.file_name}"
  end

  #完整文件路径
  def file_full_path
    "#{self.file_full_folder}#{self.file_name}"
  end

  #文件放置文件夹
  def file_folder
    @file_folder||Time.now.strftime("%Y-%m")
  end

  def file_full_folder
    "#{self.root_folder_path}/#{self.file_folder}/"
  end

  def new_file_name(filename)
    if !filename.nil?
      Time.now.strftime("%Y%m%d%H%M%S") + '_' + filename
    end
  end
end