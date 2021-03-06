class Image < ActiveRecord::Base
  belongs_to :album, counter_cache: true

  belongs_to :uploader, class_name: 'User', inverse_of: :uploads

  has_and_belongs_to_many :sources, -> { order(:name).uniq }

  mount_uploader :image, ImageUploader

  before_create :set_store_dir

  after_commit :async_set_thumbnails, on: :create

  after_commit :async_set_md5, on: :create

  after_commit(on: :create) { album.touch(:contents_updated_at) }

  paginates_per 100

  def set_md5
    self.md5 = image.md5
  end

  def set_thumbnails
    if album
      album.self_and_ancestors.each { |a| a.set_thumbnail_url }
    end
  end

  def sources_attributes=(attrs)
    attrs.values.each do |source_attrs|
      associate_source(source_attrs)
    end
  end

  def album_page_num
    album.images.index(self) / self.class.default_per_page + 1
  end

  private
  def associate_source(attrs)
    if source_id = attrs.delete(:id).presence
      sources << Source.find(source_id)
    else
      unless attrs.values_at(:name, :kind).any?(&:blank?)
        sources << Source.find_or_create_by(attrs)
      end
    end
  end

  def set_store_dir
    self.store_dir = image.store_dir
  end

  def async_set_md5
    ImageChecksumer.perform_async(id)
  end

  def async_set_thumbnails
    Thumbnailer.perform_async(id)
  end
end
