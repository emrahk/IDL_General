			 CDS Time Conversion Software

			  Last updated 15 March 1995


*** Important note: The environment variable CDS_TIME has now been changed ****
*** to the more generic TIME_CONV to reflect that this software is used	   ****
*** outside of CDS or SOHO.						   ****


The procedures in this directory convert between CDS time formats.  There are
two kinds of time used within the CDS project:

TAI	International Atomic Time.  This is the time used by the SoHO
	spacecraft, and is defined as the number of standard seconds since 0h
	on 1 January 1958.  In the CDS software, TAI time is always expressed
	as a double precision floating point number.

	A distinction needs to be made between spacecraft time and geocentric
	time.  The latter includes a correction for the difference in light
	arrival time between the spacecraft and the Earth.  It has been
	discussed at SoHO SOWG meetings that all times should be geocentric
	except when explicitly labelled as spacecraft time.  The correction
	would be based on the spacecraft ephemeris supplied by the FOT.
	However, the software to calculate this correction has not been written
	yet.

UTC	Coordinated Universal Time.  This is the time standard on which civil
	time is based.  The main distinction between UTC and TAI, at least
	since 1 January 1972, is that occasionally a "leap second" is inserted
	into the UTC time to keep it in sync with the rotation of the earth.
	(Before 1972 the situation was more complicated.)  TAI time has no leap
	seconds.  Therefore, in order to convert between the two kinds of time,
	one needs to know when leap seconds were added to the UTC time.  This
	information is maintained within the file "leap_seconds.dat" in the
	directory given by the environment variable TIME_CONV.

	Note that if time differences between observations are needed to an
	accuracy of a second and the observations are separated by more than a
	day then the UTC times should be converted to TAI before differencing
	in case there is an intervening leap-second.

	Some operating systems, such as VMS and MacOS, keep track only of local
	time, not UTC.  In such cases, one can store the difference in hours
	(local-UTC) in the file "local_diff.dat" in the same TIME_CONV
	directory as "leap_seconds.dat" above.  For example, for U.S. Eastern
	Standard Time, this file would contain the value -5.

	It is not necessary for "leap_seconds.dat" and "local_diff.dat" to be
	in the same directory.  One can define TIME_CONV to be a set of
	directories, using the same format one would use for IDL_PATH.  That
	way, one can have a single "leap_seconds.dat" file which is common
	among a number of computers (e.g. through NFS or mirror), and a
	separate "local_diff.dat" file for each computer.

	If the computer is running on GMT rather than local time, one can
	signify this by adding a second line to the "local_diff.dat" file with
	the letters "GMT".

	There are three formats that the CDS software uses for UTC, all of
	which are calendar-based.  These are:

	Internal:  Referred to as "INT" in any routine names.  A structure
		   containing the following elements as longword integers:

		MJD:	The Modified Julian Day number.  This is defined as the
			ordinary Julian Day number minus 2400000.5 The ".5"
			represents the fact that MJD numbers begin at midnight,
			whereas JD numbers begin at noon.

		TIME:	The time of day, in milliseconds since the beginning of
			the day.

	External:  Referred to as "EXT" in any routine names.  A structure
		   containing the elements, YEAR, MONTH, DAY, HOUR, MINUTE,
		   SECOND, and MILLISECOND as shortword integers.

	String:	   Referred to as "STR" in any routine names.  A calendar date
		   in ASCII string format.  This format is subdivided into the
		   following subcategories.

		CCSDS:	A string variable containing the calendar date in the
			format recommended by the Consultative Committee for
			Space Data Systems (ISO 8601), e.g.

				"1988-01-18T17:20:43.123Z"

		ECS:	A variation on the CCSDS format used by the EOF Core
			System.  The "T" and "Z" separators are eliminated, and
			slashes are used instead of dashes in the date, e.g.

				"1988/01/18 17:20:43.123"

		VMS:	Similar to that used by the VMS operating system, this
			format uses a three-character abbreviation for the
			month, and rearranges the day and the year, e.g.

				"18-JAN-1988 17:20:43.123"

		STIME:	Based on !STIME in IDL, this format is the same as the
			VMS format, except that the time is only given to 0.01 
			second accuracy, e.g.

				"18-JAN-1988 17:20:43.12"

		   Other string types may be added in the future.

The following procedures are used to convert between the different time
formats:

	OBT2TAI	  Converts the 6-byte SoHO on-board time (OBT/LOBT) to TAI
		  format.

	TAI2UTC	  Converts TAI times to any one of the CDS UTC formats.
	UTC2TAI   Converts any one of the CDS UTC formats to TAI.

	INT2UTC	  Converts internal time to either external or CCSDS format.
	UTC2INT	  Converts either external or CCSDS time to internal format.

	STR2UTC   Converts string time to either internal or external format.
	UTC2STR   Converts either internal or external time to string format.

      ANYTIM2UTC  Converts any CDS format to UTC format
      ANYTIM2CAL  COnverts any CDS format to a variety of calendar formats.

In addition, there are also the following routines:

	UTC2DOW	  Calculates the day of the week from any of the UTC formats.
	UTC2DOY	  Calculates the day of the year from any of the UTC formats.
        DOY2UTC   Converts from day of year number to UTC format.
       
	GET_UTC   Gets the current UTC date/time from the system clock in any
		  one of the CDS UTC formats.

	CHECK_INT_TIME	Checks the internal time for consistency.

        CDS2JD    Calculate full Julian day equivalent of CDS date/time.

	LOCAL_DIFF  Returns the difference in hours between local and UTC time.
       
The following are used in the UTPLOT programs, and take no account of leap
seconds:

	UTC2SEC	  Converts CDS UTC time format to seconds since MJD=0.
	SEC2UTC	  Converts seconds since MJD=0 to CDS UTC time format.

The following are essentially internal routines:

	DATE2MJD       Converts dates to MJD numbers.
	MJD2DATE       Converts MJD numbers to dates.

	GET_LEAP_SEC   Gets the MJD numbers for days with leap seconds.

Note that where a routine uses a particular form of time, any of the specified
formats for that time may be used as input to the routine--the code can
distinguish the formats.  Thus, in the routine STR2UTC the input variable may
be any recognized string format, including CCSDS or ECS, plus some variations
on these.  In UTC2TAI the input can be any of the UTC formats mentioned above
(INT, EXT, STR).

If there is a choice on output, then this is controlled by keywords.  For
instance, when using INT2UTC the keywords /EXTERNAL, /CCSDS or /ECS would be
used to determine the format of the UTC output.


----------------------------------------------------------------------------
As of 21-Apr-95 the files are:

 
 
Directory:  /tmp_mnt/sohos1/solg2/cds/soft/util/time/
 
ANYTIM2CAL()      - Converts (almost) any time format to calendar format.
ANYTIM2UTC()      - Converts (almost) any time format to CDS UTC format.
CDS2JD()          - Converts any CDS time format to full Julian day.
CHECK_EXT_TIME    - Checks CDS external time values for logical consistency.
CHECK_INT_TIME    - Checks CDS internal time values for logical consistency.
DATE2MJD()        - Convert calendar dates to Modified Julian Days.
DOY2UTC()         - Converts day of year to internal CDS time format.
GET_LEAP_SEC      - Returns the dates of all known leap seconds.
GET_UTC           - Gets the current date/time in UTC.
INT2UTC()         - Converts CDS internal time to calendar format.
LOCAL_DIFF()      - Gets the current difference between local and UTC time.
MJD2DATE          - Converts MJD to year, month, and day.
SEC2UTC()         - Converts seconds since MJD=0 to CDS UTC time format.
STR2UTC()         - Parses UTC time strings.
TAI2UTC()         - Converts TAI time in seconds to UTC calendar time.
UTC2DOW()         - Calculates the day of the week from CDS UTC date/time.
UTC2DOY()         - Calculates the day of the year from CDS UTC date/time.
UTC2INT()         - Converts CCSDS calendar time to internal format.
UTC2SEC()         - Converts CDS UTC time format to seconds since MJD=0.
UTC2STR()         - Converts CDS external time in UTC to string format.
UTC2TAI()         - Converts UTC calendar time to TAI.
