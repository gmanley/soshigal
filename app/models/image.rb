class Image < ActiveRecord::Base
  attr_accessible :image, :source, :photographer, :uploader

  belongs_to :album, counter_cache: true
  belongs_to :source
  belongs_to :photographer
  belongs_to :uploader, class_name: 'User', inverse_of: :uploads

  mount_uploader :image, ImageUploader

  paginates_per 100

  validates :md5, on: :create,
                  uniqueness: { scope: :album_id }

  before_validation :set_md5
  after_commit :async_set_thumbnails, on: :create
  before_create :set_store_dir

  def set_thumbnails
    unless album.nil?
      album.self_and_ancestors.each { |a| a.set_thumbnail_url }
    end
  end

  def source=(source)
    self.source_id = Source.find_or_create_by_name(source).id
  end

  def photographer=(photographer)
    self.photographer_id = Photographer.find_or_create_by_name(photographer).id
  end

  private
  def set_md5
    self.md5 = image.md5
  end

  def set_store_dir
    self.store_dir = image.store_dir
  end

  def async_set_thumbnails
    if Rails.env.production?
      Thumbnailer.perform_async(id)
    else
      set_thumbnails
    end
  end
end
