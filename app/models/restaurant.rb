class Restaurant < ApplicationRecord
  with_options presence: true do
    validates :name, :postal_code, :address
  end
  validate :name_uniqueness_check
  validate :address_accurary_check
  validate :postal_code_accurary_check

  mount_uploader :image, ImageUploader

  belongs_to :user
  belongs_to :country
  has_many :reports, dependent: :destroy
  has_many :likes, dependent: :destroy

  include JpPrefecture
  jp_prefecture :prefecture_code

  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  private

  def name_uniqueness_check
    if name.present? && Restaurant.where.not(id: id).exists?(name: name)
      errors.add(:name, "はすでに登録されているようです。お店を探してレポを書こう！")
    end
  end

  def address_accurary_check
    prefectures = ['都', '道', '府', '県']
    cities = ['市', '区', '町', '村']

    unless address.present? && prefectures.any? { |prefecture| address.include?(prefecture) }
      errors.add(:address, "に都道府県名を入力してください。")
    end

    unless address.present? && cities.any? { |city| address.include?(city) }
      errors.add(:address, "に市区町村名を入力してください。")
    end
  end

  def postal_code_accurary_check
    return if postal_code.blank?
    postal_code_str = postal_code.to_s

    unless postal_code_str.length == 7
      errors.add(:postal_code, "は7桁入力してください")
    end

    unless postal_code_str.match?(/\A\d+\z/)
      errors.add(:postal_code, "には数字のみ入力してください")
    end
  end
end
