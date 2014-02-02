module NotificationsHelper

  # Get a array of html classes from Notification attributes
  # @param note Notification
  # @return array
  def notification_classes note
    classes = ["notification"]
    classes.push(note.event) if note.event?
    classes.push(note.level_to_s) if note.level?
    note.read ? classes.push("read") : classes.push("unread")
  end



end