@isWorkday = (date) ->
    date.day() in [1..5]

@isWorkhours = (date) ->
    date.hour() in [9..17]

## ближайшее рабочее время
closestWorktime = (time) ->
    # если в рабочем диапазоне,то возвращать
    if isWorkday(time) and isWorkhours(time)
        time
    else
        if isWorkday(time) and time.hours() < 9
            time.hours(9).minutes(0).seconds(0)
        else
            time.add(1,'day')
            time.hours(9).minutes(0).seconds(0)
            while not isWorkday(time)
                time.add(1,'day')
                time.hours(9).minutes(0).seconds(0)
            time
# возвращает в минутах разницу во времени между датами
@workingHoursBetweenDates = (startDate, endDate) ->
    if startDate < endDate
        time_a = closestWorktime moment(startDate)
        time_b = closestWorktime moment(endDate)
        direction = 1
    else
        time_a = closestWorktime moment(endDate)
        time_b = closestWorktime moment(startDate)
        direction = -1

    if time_a.isSame(time_b,'day')
        parseInt moment.duration(time_b-time_a).asMinutes() * direction
    else
        end_of_first_workday = moment(time_a).hours(18).minutes(0).seconds(0)

        first_day_duration = moment.duration(end_of_first_workday - time_a).asMinutes()

        begin_of_last_workday = moment(time_b).hours(9).minutes(0).seconds(0)

        last_day_duration = moment.duration(time_b - begin_of_last_workday).asMinutes()

        currentTime = end_of_first_workday.startOf('day').add(1,'day')

        begin_of_last_workday.subtract(1,'day')

        workhours_between = 0

        while currentTime.isBefore(begin_of_last_workday)
            workhours_between +=9 if isWorkday(currentTime)
            currentTime.add(1,'day')

        parseInt (first_day_duration + workhours_between * 60 + last_day_duration)*direction

# Duration in seconds
@dateFromDuration = (duration, start_date = new Date()) ->
    start = closestWorktime moment(start_date)

    end_of_day = moment(start).hours(18).minutes(0).seconds(0)

    current_duration  = (end_of_day - start) / 1000
    
    while duration - current_duration > 0
        duration -= current_duration
        start = closestWorktime end_of_day.seconds(1)
        end_of_day = moment(start).hours(18).minutes(0).seconds(0)
        current_duration  = (end_of_day - start) / 1000

    start.add(duration, 'seconds').toDate()
