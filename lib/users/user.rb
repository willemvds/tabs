module Users
  class User
    ACTIVE = 1
    INACTIVE = 0

    attr_reader :id
    attr_reader :username
    attr_reader :created_by
    attr_reader :created_at

    def initialize(id, username, is_active, created_by, created_at)
      @id = id
      @username = username
      @is_active = is_active
      @created_by = created_by
      @created_at = created_at
    end

    def active?
      @is_active
    end
  end
end
