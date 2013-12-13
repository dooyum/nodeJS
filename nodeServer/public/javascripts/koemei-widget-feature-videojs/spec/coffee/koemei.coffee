describe 'Koemei', ->

  it 'formats seconds into HH:mm:ss', ->
    expect(Koemei.secsToString(null)).toBe '00:00'
    expect(Koemei.secsToString(0)).toBe '00:00'
    expect(Koemei.secsToString(130)).toBe '02:10'
    expect(Koemei.secsToString('4500')).toBe '01:15:00'
    expect(Koemei.secsToString(300, true)).toBe '00:05:00'


  it 'formats dates to fuzzy intervals', ->
    now = new Date
    secsAgo = new Date now
    secsAgo.setSeconds now.getSeconds() - 3
    expect(Koemei.dateToFuzzy(secsAgo.toISOString())).toBe 'a few seconds ago'

    minsAgo = new Date now
    minsAgo.setMinutes now.getMinutes() - 10
    expect(Koemei.dateToFuzzy(minsAgo.toISOString())).toBe '10 minutes ago'

    hoursAgo = new Date now
    hoursAgo.setHours now.getHours() - 7
    expect(Koemei.dateToFuzzy(hoursAgo.toISOString())).toBe '7 hours ago'

    daysAgo = new Date now
    daysAgo.setUTCDate now.getUTCDate() - 23
    expect(Koemei.dateToFuzzy(daysAgo.toISOString())).toBe '23 days ago'

    monthsAgo = new Date now
    monthsAgo.setUTCMonth now.getUTCMonth() - 4
    expect(Koemei.dateToFuzzy(monthsAgo.toISOString())).toBe '4 months ago'


  describe 'enables/disables the debugging messages', ->

    debugParam = undefined


    beforeEach ->
      spyOn console, 'log'
      spyOn console, 'warn'
      spyOn console, 'error'
      spyOn(Koemei, 'getParameterByName').andCallFake -> debugParam


    it 'does nothing by default', ->
      Koemei.log()
      Koemei.warn()
      Koemei.error()
      expect(console.log).not.toHaveBeenCalled()
      expect(console.warn).not.toHaveBeenCalled()
      expect(console.error).not.toHaveBeenCalled()


    it 'accepts an argument and a URL `debug` parameter', ->
      debugParam = undefined
      Koemei.setDebug false
      Koemei.log()
      expect(console.log.calls.length).toBe 0

      Koemei.setDebug true
      Koemei.log()
      expect(console.log.calls.length).toBe 1

      debugParam = 'a random value means false'
      Koemei.setDebug 'this value is overridden by debugParam'
      Koemei.log()
      expect(console.log.calls.length).toBe 1

      debugParam = 'on'
      Koemei.setDebug false
      Koemei.log()
      expect(console.log.calls.length).toBe 2

      debugParam = 'true'
      Koemei.setDebug false
      Koemei.log()
      expect(console.log.calls.length).toBe 3

      debugParam = '1'
      Koemei.setDebug false
      Koemei.log()
      expect(console.log.calls.length).toBe 4
