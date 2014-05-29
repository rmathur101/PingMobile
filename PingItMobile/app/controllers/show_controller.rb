class ShowController < UIViewController
  def viewDidLoad
    super
    self.view.backgroundColor = UIColor.canvasYellow
    # self.
    p App::Persistence['show_info']

    # App::Persistence['show_info'][:title]
    # App::Persistence['show_info'][:description]
    # App::Persistence['show_info'][:address]
    # App::Persistence['show_info'][:status]
    # App::Persistence['show_info'][:start_time]

    p App::Persistence['show_info']

    @data = {}
    @data[:event_id] = App::Persistence['show_info'][:id]
    @data[:uid] = App::Persistence['current_uid']

    # (CGRectMake(10, 10, 100, 100)



    # (NSDate.dateWithString(event_time)).strftime("%I:%M %p")


    @event_title = UILabel.alloc.initWithFrame(CGRectMake(20, 15, 300, 200))
    @event_title.text = App::Persistence['show_info'][:title]
    @event_title.textAlignment = NSTextAlignmentCenter
    # @event_title.sizeToFit
    # @event_title.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 7)
    self.view.addSubview(@event_title)

    @event_description = UILabel.alloc.initWithFrame(CGRectMake(20, 70, 300, 200))
    @event_description.text = App::Persistence['show_info'][:description]
    # @event_description.sizeToFit
    # @event_description.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 6)
    self.view.addSubview(@event_description)

    @event_address = UILabel.alloc.initWithFrame(CGRectMake(20, 100, 300, 200))
    @event_address.text = App::Persistence['show_info'][:address]
    # @event_address.sizeToFit
    # @event_address.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 5)
    self.view.addSubview(@event_address)

    @event_status = UILabel.alloc.initWithFrame(CGRectMake(20, 130, 300, 200))
    @event_status.text = App::Persistence['show_info'][:status]
    # @event_status.sizeToFit
    # @event_status.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4)
    self.view.addSubview(@event_status)

    @event_start = UILabel.alloc.initWithFrame(CGRectMake(20, 160, 300, 200))
    start = (NSDate.dateWithString(App::Persistence['show_info'][:start_time])).strftime("%I:%M %p")
    @event_start.text = start
    # @event_start.sizeToFit
    # @event_start.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 3)
    self.view.addSubview(@event_start)
    
    @event_end = UILabel.alloc.initWithFrame(CGRectMake(20, 190, 300, 200))
    ending = (NSDate.dateWithString(App::Persistence['show_info'][:end_time])).strftime("%I:%M %p")
    @event_end.text = ending
    self.view.addSubview(@event_end) 

    @yes_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @yes_button.setTitle("OMG CAN'T WAIT.", forState: UIControlStateNormal)
    @yes_button.frame = [[10, 300], [250, 50]]
    @yes_button.backgroundColor = UIColor.whiteColor
    @yes_button.addTarget(self, action: :select_yes, forControlEvents: UIControlEventTouchUpInside)
    self.view.addSubview(@yes_button)


    @no_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @no_button.setTitle("Nahhhhh.", forState: UIControlStateNormal)
    @no_button.frame = [[10, 400], [250, 50]]
    @no_button.backgroundColor = UIColor.whiteColor
    @no_button.addTarget(self, action: :select_no, forControlEvents: UIControlEventTouchUpInside)
    self.view.addSubview(@no_button)


#TO DO (SHOW)
    #title
    #start_time - #end_time
    #rsvp count
    #description
    #google image satic pic (status)
    #address
    #yes / no ---> this is going to require an http request 

  end

#------------------------------------------------------------------the alert box is rendered in the callback function of the rsvp request 
  def select_yes
    @data[:rsvp_status] = "attending"
    puts "@data HASH IS BELOW"
    p @data

    Event.send_rsvp_info(@data) do |event|
      @alert_box = UIAlertView.alloc.initWithTitle("What up dude.",
        message: "PROCESSING REQUEST",
        delegate: nil,
        cancelButtonTitle: "ok",
        otherButtonTitles: nil)
      puts "THIS IS RESPONSE FROM HTTP REQUEST IN SELECT_YES"
      p event 
      @alert_box.show
    end
  end

  def select_no
    @data[:rsvp_status] = "no"
    puts "@data HASH IS BELOW"
    p @data

    Event.send_rsvp_info(@data) do |event|
      @alert_box = UIAlertView.alloc.initWithTitle("What up dude.",
        message: "You suck and I hate you.",
        delegate: nil,
        cancelButtonTitle: "ok",
        otherButtonTitles: nil)
      puts "THIS IS RESPONSE FROM HTTP REQUEST IN SELECT_NO"
      p event      
      @alert_box.show
    end
  end




end