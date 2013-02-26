module Her
  class PaginatedCollection < Collection
    def current_page
      metadata[:current_page].to_i
    end

    def per_page
      metadata[:per_page].to_i
    end

    def total_entries
      metadata[:total_entries].to_i
    end

    def total_pages
      return 0 if total_entries == 0 || per_page == 0
      (total_entries.to_f / per_page).ceil
    end
  end
end
