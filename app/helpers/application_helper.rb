module ApplicationHelper
  def listing_status_badge_class(status)
    case status
    when "unsold"
      "bg-blue-100 text-blue-800"
    when "in_process"
      "bg-yellow-100 text-yellow-800"
    when "sold"
      "bg-green-100 text-green-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def order_status_badge_class(status)
    case status
    when "pending"
      "bg-yellow-100 text-yellow-800"
    when "completed"
      "bg-green-100 text-green-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    when "refunded"
      "bg-gray-100 text-gray-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
