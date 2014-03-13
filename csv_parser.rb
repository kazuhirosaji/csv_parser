class CsvParser
  STOP = 0
  START = 1
  WAITDONE = 2

  START_MSG = "start"
  WAITDONE_MSG = "end"
  STOP_MSG = "total"

  def initialize
    @state = STOP
    @times = {}
    if ARGV[0]
      @file = ARGV[0]
    else
      p "please input csv file name"
      exit 3
    end
  end

  def parse
    open(@file) do |f|
      while line = f.gets        
        record = line.chomp.split("\t")
        if record.size > 0
          next if ignore? record
          set_total record if record.size > 1
          change_state record
          check_done record
        end
      end
    end
  end

  def ignore? record
    return true if @state == START && record[1] == STOP_MSG
    return true if @state == WAITDONE && record[1] == WAITDONE_MSG
    false
  end

  def set_total record
    return if @state == STOP
    kind = record[1].to_sym
    if @times[kind]
      @times[kind] += record[2].to_i
    else
      @times[kind] = record[2].to_i
    end
  end

  def change_state record
    @state = START if record[0].include?(START_MSG)
    @state = WAITDONE if record[0].include?(WAITDONE_MSG)
    #p @state
  end

  def check_done record
    if record[0].include?(STOP_MSG) && @state == WAITDONE
      @state = STOP
      p @times
      @times = {}
    end
  end
end

parser = CsvParser.new
parser.parse

