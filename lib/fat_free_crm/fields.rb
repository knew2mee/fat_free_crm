# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module FatFreeCRM
  module Fields

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def has_fields
        unless included_modules.include?(InstanceMethods)
          extend SingletonMethods
          include InstanceMethods
        end
      end
    end


    module SingletonMethods
      def fields
        Field.where(:klass_name => self.name).order(:position)
      end

      def core_fields
        fields.where(:type => "CoreField")
      end

      def custom_fields
        fields.where(:type => "CustomField")
      end
    end


    module InstanceMethods
      def assign_attributes(new_attributes, options = {})
        super
      # If attribute is unknown, a new custom field may have been added.
      # Refresh columns and try again.
      rescue ActiveRecord::UnknownAttributeError
        self.class.reset_column_information
        super
      end

      def method_missing(method_id, *args, &block)
        if method_id.to_s =~ /^cf_/
          # Refresh columns and try again.
          self.class.reset_column_information
          respond_to?(method_id) ? send(method_id, *args) : nil
        else
          super
        end
      end
    end
  end
end

