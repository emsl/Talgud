class Mail < ActiveRecord::Base
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :from, :text
  column :to, :text
  column :reply_to, :text
  
  column :event_id, :integer
  column :subject, :text
  column :message, :text

  validates_length_of :message, :maximum => 5000
  validates_presence_of :subject, :message, :from, :to, :reply_to

  belongs_to :event

  def from_emails
    ["#{Talgud.config.mailer.from_name} <#{Talgud.config.mailer.from_address}>"]
  end

  def to_emails
    return [] if self.event.blank? or self.event.event_participants.empty?
    res = self.event.event_participants.collect(&:email).inject(Array.new) do |memo, item|
      item = item.strip
      memo << item if item =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
      memo
    end
    res.uniq
  end
  
  def reply_to_emails
    return [] if self.event.blank?
    res = self.event.managers.collect(&:email).inject(Array.new) do |memo, item|
      item = item.strip
      memo << item if item =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
      memo
    end
    res.uniq
  end
end
