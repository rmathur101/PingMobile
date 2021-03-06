class IndexController < UIViewController
  def viewDidLoad
    super
    self.title = "Events"
    events_table = UITableView.alloc.initWithFrame(self.view.bounds)
    # self.view.backgroundColor = UIColor.canvasYellow
    # self.view.indexColor = UIColor.offWhite
    # self.view.indexBackgroundColor = charcoal
    events_table.separatorColor = UIColor.offWhite
    events_table.backgroundColor = UIColor.charcoal 
    self.view.addSubview(events_table)

    @data = []
     
    timer = EM.add_periodic_timer 5.0 do
      lat = App::Persistence["user_latitude"]
      long = App::Persistence["user_longitude"]
      if lat && long
        puts "THIS TIMER IS WORKING"

        @user_position = CLLocation.alloc.initWithLatitude(lat, longitude: long) #this is hardcoded but will be updatd on phone using the App::Persistence

        info = {latitude: lat, longitude: long, uid: App::Persistence['current_uid']}
        Event.get_events(info) do |events|
          p "?????????????????????????????????????????????????????????????????????????????????????????????"
          p events
          @data = []
          App::Persistence['events'] = events

          unordered_events = events[:pingas_active_in_radius] + events[:pingas_pending_in_radius]

          @events_arr = unordered_events.sort_by do |hash|
            (NSDate.dateWithString(hash[:start_time])).timeIntervalSinceReferenceDate
          end


          @events_arr.each do |event_obj|

            @event_position = CLLocation.alloc.initWithLatitude(event_obj[:latitude], longitude: event_obj[:longitude])
            distance_meters = @user_position.distanceFromLocation(@event_position)
            distance_miles = (distance_meters / 1609).round(2)
            
            #-------------------------------Attending Events-----------------------------------
            #if the event is like really near by I can send a request to the controller with the uid, the event id, and I can check to see if this event has an RSVP on it for attending - if it does then I can change the status to the attending on that user pinga and then we will have that in the data base 
            #--------------------------------------------------------------------------------------
            
            now_date = NSDate.date#no description
            event_time = event_obj[:start_time]

            convert_event_time = ((NSDate.dateWithString(event_time)).getutc).timeIntervalSinceReferenceDate #DON'T THINK I NEED TO CONVERT TO DATE WITH STRING
            p "THIS IS THE EVENT TIME"
            p (NSDate.dateWithString(event_time)).getutc
            p "THIS IS THE LOCAL TIME"
            p now_date
            # convert_event_time_no_interval = (NSDate.dateWithString(event_time)).getutc
            # p "This is event time: #{convert_event_time_no_interval} with dateWithString"
            difference = convert_event_time - ((NSDate.date)).timeIntervalSinceReferenceDate
            # p "This is difference: #{difference}"
            hours = (difference / 60 / 60 ).floor
            p "This is hours: #{hours}"
            min = ((difference - (hours * 60 * 60)) / 60).floor 

            puts "MINUTES"
            rounded_minutes = (min/60.0).round(2)
            puts "HOURS"
            # p hours
            puts "HOURS (WITH MINUTES)"
            h_m = (hours + rounded_minutes).round(2)

            time_left = "#{ h_m } hours"
            time_left = "#{min} minutes" if hours < 1 && hours > 0
            time_left = "" if hours < 0 
            # time_left = "#{min} minutes" if hours < 1
            # time_left = "Happening Now" if hours <= 0
            
            event_obj_array = []
            event_obj_array.push(event_obj[:title])
            event_obj_array.push(time_left)
            event_obj_array.push("#{distance_miles.round(2)} miles")
            event_obj_array.push("#{Event.category_from_id(event_obj[:category_id])}_#{event_obj[:status]}.png")
            event_obj_array.push()

            @data.push(event_obj_array)  
          end
          events_table.reloadData
        end
      end
    end

    #data stuff 
    events_table.dataSource = self #set our controller as the table's dataSource
    events_table.delegate = self #delegate has to do with how the table looks and how the user interacts with it
  end

  def initWithNibName(name, bundle: bundle)
    super
    @index = UIImage.imageNamed('index.png')
    self.tabBarItem = UITabBarItem.alloc.initWithTitle('Events', image: @index, tag: 1)
    # self.tabBarItem.setFinishedSelectedImage(@eventSel, withFinishedUnselectedImage:@event)
    self
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath) #special method for picking out cell
    #return the UITableViewCell for the row
    @reuseIdentifier ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:@reuseIdentifier)
    end
    #this is presupposing that the format of thedata is an array of arrays
    cell.textLabel.text = @data[indexPath.row][0]
    # cell.detailTextLabel.text = @data[indexPath.row[1] + " " + @data[indexPath.row][2]
    cell.detailTextLabel.text = "#{@data[indexPath.row][2]}    #{@data[indexPath.row][1]}"
    #adding acessorytypes to all cells 
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.imageView.image = UIImage.imageNamed(@data[indexPath.row][3])
    cell.backgroundColor = UIColor.charcoal

    cell.textColor = UIColor.offWhite
    cell.detailTextLabel.color = UIColor.offWhite

    text_font = UIFont.fontWithName("GillSans", size: 14.0)
    cell.detailTextLabel.font = text_font

    title_font = UIFont.fontWithName("GillSans-Bold", size: 18.0)
    cell.textLabel.font = title_font

    cell
  end

  def tableView(tableView, numberOfRowsInSection: section) #this is just the count of the data
    #return the number of rows
    @data.count
  end


  #if a row was selected 
  def tableView(tableView, didSelectRowAtIndexPath: indexPath) #this is what runs when you pick one of the rows within the table 
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    @new_view = ShowController.alloc.initWithNibName(nil, bundle:nil)

    App::Persistence['show_info'] = @events_arr[indexPath.row] 

    self.navigationController.pushViewController(@new_view, animated: true)   
  end

  def request_events
  end


end