class Source < ActiveRecord::Base
  include Autocompleteable

  POSSIBLE_KINDS = %w[photographer website]

  attr_accessible :name, :url, :kind

  validates :kind, presence: true,
                   inclusion: {
                     in: POSSIBLE_KINDS,
                     message: "%{value} is not a valid kind of source"
                   }

  validates :name, presence: true,
                   uniqueness: {
                    scope: :kind,
                    case_sensitive: false
                   }

  has_and_belongs_to_many :images, uniq: true

  scope :websites, where(kind: 'website')

  scope :photographers, where(kind: 'photographer')

  def self.merge!(source_ids)
    sources = Source.where(id: source_ids).order('created_at ASC')
    image_ids = sources.map { |source| source.image_ids }.flatten
    merged_source = sources.pop
    merged_source.image_ids = image_ids

    sources.destroy_all if merged_source.save(validate: false)
  end

  def name=(name)
    self[:name] = name.strip
  end

  def to_s
    name
  end
end
