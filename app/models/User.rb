class User
  include ActiveModel::Serialization
  include GlobalID::Identification
  attr_accessor :id, :latitude, :longitude

  def self.find(id)
    self.new(id)
  end

  def id
    @id
  end

  def initialize(user_id, fields = nil)
    @id = user_id

    unless fields.nil?
      @latitude = fields['lat']
      @longitude = fields['long']

      return
    end

    firebase = Firebase::Client.new(Rails.configuration.x.firebase_uri)
    response = firebase.get("users/#{@id}/")

    if defined? response.body['userId']
      @latitude = response.body['lat']
      @longitude = response.body['long']
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def self.all
    firebase = Firebase::Client.new(Rails.configuration.x.firebase_uri)
    response = firebase.get("users")

    all = Array.new
    response.body.each_with_index do |destination, counter|
      all.push self.new(counter, destination)
    end

    all
  end

  def attributes
    {
        :id => @id,
        :latitude => @latitude,
        :longitude => @longitude
    }
  end
  def lat_lon_string
    @latitude.to_s+','+@longitude.to_s
  end
end


#
# class User
#   include ActiveModel::Serialization
#   attr_accessor :id, :latitude, :longitude
#
#   def initialize(user_id)
#     @id = user_id
#     update
#   end
#
#   def update
#     firebase = Firebase::Client.new(Rails.configuration.x.firebase_uri)
#     response = firebase.get("users/#{@id}/")
#     if defined? response.body['userId']
#       @latitude = response.body['lat']
#       @longitude = response.body['long']
#     else
#       raise ActiveRecord::RecordNotFound
#     end
#   end
#
#   def attributes
#     {
#         :id => @id,
#         :latitude => @latitude,
#         :longitude => @longitude
#     }
#   end
#   def lat_lon_string
#     @latitude.to_s+','+@longitude.to_s
#   end
# end