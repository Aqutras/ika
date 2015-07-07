# Ika
[![Gem Version](https://badge.fury.io/rb/ika.svg)](http://badge.fury.io/rb/ika)
[![Circle CI](https://circleci.com/gh/Aqutras/ika.svg?style=shield)](https://circleci.com/gh/Aqutras/ika)
[![Coverage Status](https://coveralls.io/repos/Aqutras/ika/badge.svg?branch=master)](https://coveralls.io/r/Aqutras/ika?branch=master)

Ika implements the function that export/import ActiveModel data with json. Ika also supports [carrierwave](https://github.com/carrierwaveuploader/carrierwave).

## Installation

In Rails, add it to your Gemfile:

```ruby
gem 'ika'
```

## Usage

You can use `export` or `import` method on your model or relation.

### Example

In case: `Group` has many tags and `User` belongs to multiple groups with `GroupUsers` such as below.

```ruby
class User < ActiveRecord::Base
  has_many :group_users
  has_many :groups, through: :group_users
end

class GroupUsers < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
end

class Group < ActiveRecord::Base
  has_many :group_users
  has_many :users, through: :group_users
  has_many :tags
end

class Tag < ActiveRecord::Base
  belongs_to :group
end
```

Now you can export with `export` method on your model or relation and import with `import` method on your model.

```ruby
require 'json'
# with no options

JSON.parse User.export
# => [{"id":1,"name":"iruca3"},{"id":2,"name":"inkling"}]
JSON.parse User.where(id: 1).export
# => [{"id":1,"name":"iruca3"}]
JSON.parse User.find(id: 2).export
# => {"id":2,"name":"inkling"}

# with include option
JSON.parse User.export(include: :groups)
# => [{"id":1,"name":"iruca3","groups":[{"id":1,"name":"aqutras"},{"id":2,"name":"Splatoon"}]},{"id":2,"name":"inkling","groups":[{"id":2,"name":"Splatoon"}]}]
data = JSON.parse(User.find(id: 1).export(include: [{groups: [:tags]}]))
# => {"id":1,"name":"iruca3","groups":[{"id":1,"name":"aqutras","tags":[{"id":1,"name":"Company"}]},{"id":2,"name":"Splatoon","tags":[{"id":2,"name":"Game"},{"id":3,"name":"Inkling"}]}]}

# import (id, created_at and updated_at are completely imported with the same value)
User.destroy_all
Group.destroy_all
Tag.destroy_all
User.import(data)

# sync mode is available.
User.import(User.where(id: 1).export, sync: true)
User.exist?(id: 2)
# => false
```

## Others

* **DO NOT USE sync mode if you are using `include` option.**
* If the same id exists, Ika uses `UPDATE`.
* Uploaded files by `carrierwave` will be checked their md5 hash and do nothing if they exist and md5 is matched.

## License

Copyright (c) 2015 Aqutras
This project rocks and uses MIT-LICENSE.
