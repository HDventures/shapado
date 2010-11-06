class Badge
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPES = %w[gold silver bronze]
  GOLD = %w[rockstar popstar fanatic service_medal famous_question celebrity
            great_answer great_question stellar_question]
  SILVER = %w[popular_person guru favorite_question addict good_question
              good_answer notable_question civic_duty enlightened necromancer]
  BRONZE = %w[pioneer supporter critic inquirer troubleshooter commentator
              merit_medal effort_medal student shapado editor popular_question
              friendly interesting_person citizen_patrol cleanup disciplined
              nice_answer nice_question peer_pressure self-learner scholar autobiographer
              organizer tutor]

  def self.TOKENS
    @tokens ||= GOLD + SILVER + BRONZE
  end

  identity :type => String

  referenced_in :user
  validates_presence_of :user

  referenced_in :group
  validates_presence_of :group

  field :token, String, :required => true, :index => true
  field :type, String, :required => true

  field :for_tag, Boolean

  field :source_id, String
  field :source_type, String
#   belongs_to :source, :polymorphic => true # FIXME mongoid

  validates_inclusion_of :type,  :within => TYPES
  validates_inclusion_of :token, :within => self.TOKENS, :if => Proc.new { |b| !b.for_tag }

  before_save :set_type

  def self.gold_badges
    self.find_all_by_type("gold")
  end

  def to_param
    self.token
  end

  def name
    @name ||= I18n.t("badges.shared.#{self.token}.name", :default => self.token.titleize.downcase) if self.token
  end

  def description
    @description ||= I18n.t("badges.shared.#{self.token}.description") if self.token
  end

  def self.type_of(token)
    if BRONZE.include?(token)
      "bronze"
    elsif SILVER.include?(token)
      "silver"
    elsif GOLD.include?(token)
      "gold"
    end
  end

  def type
    self[:type] ||= Badge.type_of(self.token)
  end

  protected
  def set_type
    self[:type] ||= self.class.type_of(self[:token])
  end
end
