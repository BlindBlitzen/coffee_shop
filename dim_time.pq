let
    Source = List.Times(#time(0,0,0),24*60*60,#duration(0,0,0,1)),
    ConvertToTable = Table.FromList(Source, Splitter.SplitByNothing(), type table[Time = Time.Type]),
    Add_TimeKey = Table.AddIndexColumn(ConvertToTable, "TimeKey", 0, 1),
    Add_CommonTimeFields = 
        Table.AddColumn(Add_TimeKey, "CommonTimeFields",
        each
            [
                Hour_24hrTime = Time.Hour([Time]),
                Hour_12hrTime = let x = Number.Mod(Time.Hour([Time]), 12) in if x = 0 then 12 else x,
                Minute = Time.Minute([Time]),
                Second = Time.Second([Time]),
                AM_PM = if Time.Hour([Time]) < 12 then "a.m." else "p.m.",
                Hour_24hrTime_Label = Text.PadStart( Text.From( Time.Hour([Time]) ), 2, "0" ),
                Hour_12hrTime_Label = let x = Number.Mod(Time.Hour([Time]), 12) in Text.PadStart( Text.From( if x = 0 then 12 else x), 2, "0" ),       
                Minute_Label = Text.PadStart( Text.From( Time.Minute([Time]) ), 2, "0" ),
                Second_Label = Text.PadStart( Text.From( Time.Second([Time]) ), 2, "0" )
            ],
        type
            [
                Hour_24hrTime = Int64.Type,
                Hour_12hrTime = Int64.Type,
                Minute = Int64.Type,
                Second = Int64.Type,
                AM_PM = text,
                Hour_24hrTime_Label = text,
                Hour_12hrTime_Label = text,
                Minute_Label = text,
                Second_Label = text
            ]
        ),
    Expand_CommonTimeFields = Table.ExpandRecordColumn(Add_CommonTimeFields, "CommonTimeFields", {"Hour_24hrTime", "Hour_12hrTime", "Minute", "Second", "AM_PM", "Hour_24hrTime_Label", "Hour_12hrTime_Label", "Minute_Label", "Second_Label"}, {"Hour_24hrTime", "Hour_12hrTime", "Minute", "Second", "AM_PM", "Hour_24hrTime_Label", "Hour_12hrTime_Label", "Minute_Label", "Second_Label"} ),
    Add_TimeBuckets = 
        Table.AddColumn( Expand_CommonTimeFields, "TimeBuckets",
        each
            [
                60min_Time_Bucket = #time( [Hour_24hrTime],0,0),
                30min_Time_Bucket = #time( [Hour_24hrTime], Number.IntegerDivide([Minute], 30) * 30, 0 ),
                15min_Time_Bucket = #time( [Hour_24hrTime], Number.IntegerDivide([Minute], 15) * 15, 0)
            ],
        type
            [
                60min_Time_Bucket = time,
                30min_Time_Bucket = time,
                15min_Time_Bucket = time
            ]

        ),
    Expand_TimeBuckets = Table.ExpandRecordColumn(Add_TimeBuckets, "TimeBuckets", {"60min_Time_Bucket", "30min_Time_Bucket", "15min_Time_Bucket"}, {"60min_Time_Bucket", "30min_Time_Bucket", "15min_Time_Bucket"} )
in
    Expand_TimeBuckets