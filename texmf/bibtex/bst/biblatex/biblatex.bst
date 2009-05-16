% $Id: biblatex.bst,v 0.8b 2008/12/13 17:34:16 lehman beta $

% Copyright (c) 2006-2008 Philipp Lehman.
%
% Permission is granted to copy, distribute and/or modify this
% software under the terms of the LaTeX Project Public License
% (LPPL), version 1.3.
%
% The LPPL maintenance status of this software is
% 'author-maintained'.
%
% This software is provided 'as is', without warranty of any kind,
% either expressed or implied, including, but not limited to, the
% implied warranties of merchantability and fitness for a
% particular purpose.

% -------------------------------------------------------------------
% Initialization
% -------------------------------------------------------------------

ENTRY {
    % control fields
    ctrl-options
    % special fields
    entryset
    entrysubtype
    execute
    hyphenation
    key
    keywords
    label
    options
    presort
    shorthand
    sortkey
    sortname
    sorttitle
    sortyear
    xref
    % data fields
    abstract
    addendum
    address
    afterword
    annotation
    annote
    annotator
    author
    authortype
    bookauthor
    booksubtitle
    booktitle
    booktitleaddon
    chapter
    commentator
    date
    day
    doi
    edition
    editor
    editortype
    eid
    eprint
    eprinttype
    eventtitle
    file
    foreword
    gender
    howpublished
    indexsorttitle
    indextitle
    institution
    introduction
    isan
    isbn
    ismn
    isrn
    issn
    issue
    issuetitle
    issuesubtitle
    iswc
    journal
    journaltitle
    journalsubtitle
    language
    library
    location
    bookpagination
    mainsubtitle
    maintitle
    maintitleaddon
    month
    nameaddon
    note
    number
    organization
    origlanguage
    origlocation
    origpublisher
    origtitle
    origyear
    pages
    pagetotal
    pagination
    part
    pdf
    reprinttitle
    holder
    publisher
    redactor
    school
    series
    shortauthor
    shorteditor
    shorthandintro
    shortjournal
    shortseries
    shorttitle
    subtitle
    title
    titleaddon
    translator
    type
    url
    urldate
    urlday
    urlmonth
    urlyear
    venue
    version
    volume
    volumes
    year
    % custom fields
    namea
    nameb
    namec
    nameatype
    namebtype
    namectype
    lista
    listb
    listc
    listd
    liste
    listf
    usera
    userb
    userc
    userd
    usere
    userf
    verba
    verbb
    verbc
  }
  { skipbib skiplos skiplab useauthor useeditor usetranslator useprefix singletitle uniquename }
  { entryoptions date.day date.month date.year urldate.day urldate.month urldate.year
    extrayear labelhash namehash fullhash labelalpha extraalpha label.name label.uniq label.year
    sortkey.nosort sortkey.name sortkey.year sortkey.title sortkey.alpha
    sort.year sort.alph warningmsg }

INTEGERS { ctrl.debug ctrl.bibtex8 ctrl.maxline ctrl.sorting ctrl.sortlos 
           ctrl.maxnames ctrl.minnames ctrl.useauthor ctrl.useeditor ctrl.usetranslator
	   ctrl.useprefix ctrl.terseinits ctrl.labelalpha ctrl.singletitle
	   ctrl.uniquename ctrl.labelyear citecount tempctra tempctrb tempctrc
	   last.extra.num last.uniq.num }

STRINGS  { ctrl.alphaothers templist tempstrga tempstrgb last.hash last.name
           last.uniq last.year last.alph last.extra }

FUNCTION {initialize} {
  "$Revision: 0.8b $"
  #12 entry.max$ substring$
  #-3 entry.max$ substring$
  "Biblatex version: " swap$ * top$
   #0  'ctrl.terseinits :=
   #0  'ctrl.debug :=
   #0  'ctrl.labelalpha :=
   #0  'ctrl.labelyear :=
   #0  'ctrl.singletitle :=
   #0  'ctrl.uniquename :=
   #0  'ctrl.sorting :=
   #0  'ctrl.sortlos :=
   #1  'ctrl.useauthor :=
   #1  'ctrl.useeditor :=
   #0  'ctrl.usetranslator :=
   #0  'ctrl.useprefix :=
   #1  'ctrl.minnames :=
  #99  'ctrl.maxnames :=
  #79  'ctrl.maxline :=
  "+"  'ctrl.alphaothers :=
}

% -------------------------------------------------------------------
% Strings
% -------------------------------------------------------------------

MACRO {jan} { "01" }
MACRO {feb} { "02" }
MACRO {mar} { "03" }
MACRO {apr} { "04" }
MACRO {may} { "05" }
MACRO {jun} { "06" }
MACRO {jul} { "07" }
MACRO {aug} { "08" }
MACRO {sep} { "09" }
MACRO {oct} { "10" }
MACRO {nov} { "11" }
MACRO {dec} { "12" }

% -------------------------------------------------------------------
% Generic functions
% -------------------------------------------------------------------

FUNCTION {and} {
    'skip$
    { pop$ #0 }
  if$
}

FUNCTION {or} {
    { pop$ #1 }
    'skip$
  if$
}

FUNCTION {not} {
    { #0 }
    { #1 }
  if$
}

FUNCTION {ctrl:control} {
  type$ "control" =
}

FUNCTION {ctrl:set} {
  type$ "set" =
}

FUNCTION {ctrl:skipbib} {
  ctrl:control skipbib or
  ctrl:set not
  and
}

FUNCTION {ctrl:skiplos} {
  ctrl:control skiplos or
  ctrl:set not
  and
}

FUNCTION {ctrl:skiplab} {
  ctrl:control skiplab or
  ctrl:set not
  and
}

FUNCTION {ctrl:labelalpha} {
  ctrl.labelalpha
  shorthand empty$
  and
}

FUNCTION {wrap:braces} {
  duplicate$ empty$
    { pop$ "{}" }
    { "{" swap$ * "}" * }
  if$
}

FUNCTION {delimiter} {
  "0"
}

FUNCTION {subdelimiter} {
  "1"
}

FUNCTION {subsubdelimiter} {
  "2"
}

FUNCTION {maxline} {
  duplicate$ empty$
    'skip$
    { #1 ctrl.maxline substring$ }
  if$
}

FUNCTION {truncate} {
  duplicate$ empty$
    { pop$ "" }
    { #1 entry.max$ substring$ }
  if$
}

FUNCTION {normalize} {
  duplicate$ empty$
    { pop$ "" }
    { purify$
      ctrl.bibtex8
        'skip$
        { "l" change.case$ }
      if$
      truncate
    }
  if$
}

FUNCTION {enquote} {
  "'" swap$ * "'" *
}

FUNCTION {bol.to.int} {
  "true" =
    { #1 }
    { #0 }
  if$
}

FUNCTION {str.to.int} {
  'tempstrga :=
  tempstrga text.length$ 'tempctra :=
  #1 'tempctrb :=
  #0
  { tempctrb tempctra > not }
    { 'tempctrc :=
      tempstrga tempctrb #1 substring$
      chr.to.int$ "0" chr.to.int$ -
      #0
      { tempctrc #0 > }
        { tempctrc #1 - 'tempctrc :=
          #10 +
        }
      while$
      +
      tempctrb #1 + 'tempctrb :=
    }
  while$
}

FUNCTION {andothers} {
  duplicate$ num.names$ "{ff}{vv}{ll}{jj}" format.name$ "others" =
}

FUNCTION {push} {
  duplicate$ empty$
    { pop$ "" }
    { truncate }
  if$
}

FUNCTION {push:cite} {
  cite$ empty$
    { "Missing citation key" warning$ "" }
    { cite$ }
  if$
}

FUNCTION {push:presort} {
  presort empty$
    { "mm" }
    { presort normalize
      #1 #2 substring$
      "l" change.case$ }
  if$
}

FUNCTION {push:fullname} {
  author empty$ not
  useauthor
  and
    { author }
    { editor empty$ not
      useeditor
      and
        { editor }
        { translator empty$ not
	  usetranslator
	  and
            { translator }
            { "" }
	  if$
	}
      if$
    }
  if$
}

FUNCTION {push:shortname:translator} {
  translator empty$ not
  usetranslator
  and
    { translator }
    { "" }
  if$
}

FUNCTION {push:shortname:editor} {
  useeditor
    { shorteditor empty$
        { editor empty$
            { push:shortname:translator }
            { editor }
          if$
        }
        { shorteditor }
      if$
    }
    { push:shortname:translator }
  if$
}

FUNCTION {push:shortname} {
  useauthor
    { shortauthor empty$
        { author empty$
            { push:shortname:editor }
            { author }
          if$
        }
        { shortauthor }
      if$
    }
    { push:shortname:editor }
  if$
}

FUNCTION {push:sorttitle} {
  sorttitle empty$
    { title empty$
        { "" }
        { title }
      if$
    }
    { sorttitle }
  if$
  push
}

FUNCTION {shortname:hash} {
  'tempctrc :=
  'templist :=
  #1 'tempctra :=
  templist num.names$ 'tempctrb :=
  templist andothers
    { tempctrb #1 - 'tempctrb := }
    'skip$
  if$
  tempctrc #0 =
    { tempctrb 'tempctrc := }
    { tempctrb tempctrc >
	{ ctrl.minnames 'tempctrc := }
	{ ctrl.maxnames 'tempctrc := }
      if$
    }
  if$
  ""
  { tempctra tempctrc > not
    tempctrb #0 >
    and }
    { templist tempctra "{vv{}}{ll{}}{ff{}}{jj{}}" format.name$ *
      tempctra #1 + 'tempctra :=
      tempctrb #1 - 'tempctrb :=
    }
  while$
  templist andothers
  tempctrb #0 >
  or
    { "+" * }
    'skip$
  if$
}

FUNCTION {push:shortname:hash:trunc} {
  push:shortname duplicate$ empty$
    { pop$ push:sorttitle duplicate$ empty$
        { pop$ push:cite normalize }
        'skip$
      if$
    }
    { ctrl.maxnames shortname:hash }
  if$
}

FUNCTION {push:shortname:hash:full} {
  push:shortname duplicate$ empty$
    { pop$ push:sorttitle duplicate$ empty$
        { pop$ push:cite normalize }
        'skip$
      if$
    }
    { #0 shortname:hash }
  if$
}

FUNCTION {check:sortname} {
  sortname empty$
    'skip$
    { pop$ sortname }
  if$
}

FUNCTION {warning} {
  duplicate$ " in entry " * push:cite enquote * warning$
  "* " swap$ * 
  warningmsg empty$
    'skip$
    { warningmsg "\MessageBreak" * swap$ * }
  if$
  'warningmsg :=
}

FUNCTION {warning:invalid} {
  "Invalid format of field " swap$ enquote * warning
}

FUNCTION {warning:alias} {
  "Can't use " swap$ enquote * " + " * swap$ enquote * warning
}

FUNCTION {pad.number} {
  'tempctra :=
  duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
  { duplicate$ text.length$ tempctra < }
    { "0" swap$ * }
  while$
}

FUNCTION {extract.number} {
  purify$ 'tempstrga :=
  ""
  { tempstrga empty$ not }
    { tempstrga #1 #1 substring$ chr.to.int$ duplicate$
      #47 > swap$
      #58 < and
        { tempstrga #1 #1 substring$ * }
        'skip$
      if$
      tempstrga #2 global.max$ substring$ 'tempstrga :=
    }
  while$
  #1 #9 substring$
}

FUNCTION {validate.number} {
  duplicate$ extract.number 'tempstrga :=
  tempstrga =
    { #1 }
    { #0 }
  if$
  tempstrga swap$
}

FUNCTION {format.range}
{ 'tempstrga :=
  ""
  { tempstrga empty$ not }
    { tempstrga #1 #1 substring$ "-" =
      { "\bibrangedash " *
        tempstrga #2 global.max$ substring$ 'tempstrga :=
        { tempstrga #1 #1 substring$ "-" = }
          { tempstrga #2 global.max$ substring$ 'tempstrga := }
        while$
      }
      { tempstrga #1 #1 substring$ *
        tempstrga #2 global.max$ substring$ 'tempstrga :=
      }
      if$
    }
  while$
}

FUNCTION {number.prefix} {
  duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
  'tempstrga :=
  ""
  { tempstrga #1 #1 substring$
    duplicate$ empty$
      { pop$ #0 }
      { chr.to.int$ duplicate$
        #47 > swap$ #58 < and
      }
    if$
  }
    { tempstrga #1 #1 substring$ *
      tempstrga #2 global.max$ substring$ 'tempstrga :=
    }
  while$
  tempstrga #2 global.max$ substring$
}

% -------------------------------------------------------------------
% Sorting
% -------------------------------------------------------------------

FUNCTION {sortkey:name:format} {
  'templist :=
  #1 'tempctra :=
  templist num.names$ 'tempctrb :=
  templist andothers
    { tempctrb #1 - 'tempctrb := }
    'skip$
  if$
  tempctrb ctrl.maxnames >
    { ctrl.minnames 'tempctrc := }
    { ctrl.maxnames 'tempctrc := }
  if$
  ""
  { duplicate$ text.length$ entry.max$ #50 - <
    tempctra tempctrc > not and
    tempctrb #0 > and
    }
    { useprefix
        { templist tempctra "{vv}" format.name$
          duplicate$ empty$
            { pop$ "" }
            { "u" change.case$ "t" change.case$ 
              subsubdelimiter * }
          if$
          templist tempctra
          "{ll}{" subsubdelimiter *
          "ff}{"  subsubdelimiter * *
          "jj}" *
          format.name$ *
        }
        { templist tempctra
          "{ll}{" subsubdelimiter *
          "ff}{"  subsubdelimiter * *
          "vv}{"  subsubdelimiter * *
          "jj}" *
          format.name$ }
      if$
      tempctra #1 >
        { subdelimiter swap$ * }
        'skip$
      if$
      *
      tempctra #1 + 'tempctra :=
      tempctrb #1 - 'tempctrb :=
    }
  while$
  templist andothers
  tempctrb tempctrc >
  or
    { subdelimiter * "zzzz" * }
    'skip$
  if$
}

FUNCTION {sortkey:init:label} {
  push:shortname duplicate$ empty$
    { pop$ push:sorttitle }
    { check:sortname sortkey:name:format }
  if$
  normalize 'sortkey.name :=
  sortyear empty$
    { date.year push normalize #1 #4 substring$ }
    { sortyear  normalize }
  if$
  'sortkey.year :=
  push:sorttitle normalize 'sortkey.title :=
}

FUNCTION {sortkey:init:main} {
  push:fullname duplicate$ empty$
    { pop$ push:sorttitle }
    { check:sortname sortkey:name:format }
  if$
  normalize 'sortkey.name :=
}

FUNCTION {sortkey:main:string} {
  duplicate$ #1 =
    { pop$
      sortkey.name delimiter *
      sortkey.title * delimiter *
      sortkey.year *
      volume normalize #4 pad.number * delimiter *
    }
    { duplicate$ #2 =
        { pop$
          sortkey.name delimiter *
          sortkey.year * delimiter *
          sortkey.title *
          volume normalize #4 pad.number * delimiter *
        }
        { #3 =
            { sortkey.name delimiter *
              sortkey.year * delimiter *
              volume normalize #4 pad.number * delimiter *
              sortkey.title *
            }
            { "" }
          if$
        }
      if$
    }
  if$
}

FUNCTION {sortkey:main:date:year} {
  duplicate$ empty$
    { pop$ }
    { extract.number #1 #4 substring$ 
      duplicate$ empty$
        { pop$ }
        { swap$ pop$ }
      if$
    }
  if$
}

FUNCTION {sortkey:main:date} {
  duplicate$ #1 =
    { pop$
      sortyear empty$
        { "9999" date.year sortkey:main:date:year }
        { "9999" sortyear  sortkey:main:date:year }
      if$
    }
    { #2 =
        { sortyear empty$
            { "0" date.year sortkey:main:date:year }
            { "0" sortyear  sortkey:main:date:year }
          if$
          str.to.int #9999 swap$ - int.to.str$
        }
        { "" }
      if$
    }
  if$
  sortkey.name  * delimiter *
  sortkey.title * delimiter *
  volume normalize #4 pad.number * delimiter *
}

FUNCTION {sortkey:main} {
  ctrl.sorting #0 =
    { sortkey.nosort }
    { sortkey:init:main
      push:presort delimiter *
      ctrl.sorting #10 <
        { sortkey empty$
            { ctrl.sorting sortkey:main:string }
            { sortkey }
          if$
        }
        { ctrl.sorting #20 <
            { shorthand empty$
                { sortkey.alpha * }
                { shorthand normalize * }
              if$
              delimiter *
              ctrl.sorting #10 - sortkey:main:string
            }
            { ctrl.sorting #30 <
                { sortkey empty$
                    { ctrl.sorting #20 - sortkey:main:date }
                    { sortkey }
                  if$
                }
                { push:cite normalize }
              if$
            }
          if$
        }
      if$
      *
    }
  if$
  truncate
}

% -------------------------------------------------------------------
% Output
% -------------------------------------------------------------------

FUNCTION {output:indent:field} {
  duplicate$ empty$
    'skip$
    { "  " swap$ * write$ newline$ }
  if$
}

FUNCTION {output:indent:subfield} {
  duplicate$ empty$
    'skip$
    { "    " swap$ * write$ newline$ }
  if$
}

FUNCTION {output:write:field} {
  duplicate$ empty$
    { pop$ pop$ }
    { swap$ "\field" swap$ wrap:braces *
      swap$ wrap:braces * output:indent:field }
  if$
}

FUNCTION {output:write:multi} {
  duplicate$ empty$
    { pop$ pop$ }
    { swap$ "\field" swap$ wrap:braces * "{%" * output:indent:field
      "%" * output:indent:field
      "}"  output:indent:field
    }
  if$
}

FUNCTION {output:write:bool} {
  #0 >
    { "\true"  }
    { "\false" }
  if$
  swap$ wrap:braces * output:indent:field
}

FUNCTION {output:write:count} {
  int.to.str$ swap$ "\count" swap$ wrap:braces *
  swap$ wrap:braces * output:indent:field
}

FUNCTION {output:write:string} {
  duplicate$ empty$
    { pop$ pop$ }
    { swap$ "\strng" swap$ wrap:braces *
      swap$ wrap:braces * output:indent:field }
  if$
}

FUNCTION {output:write:range} {
  duplicate$ empty$
    { pop$ pop$ }
    { format.range output:write:field }
  if$
}

FUNCTION {output:write:number} {
  duplicate$ empty$
    { pop$ pop$ }
    { validate.number
        'skip$
        { swap$ duplicate$ warning:invalid swap$ }
      if$
      output:write:field
    }
  if$
}

FUNCTION {output:write:gender} {
  duplicate$ empty$
    { pop$ pop$ }
    { 'tempstrga :=
      tempstrga "sf" =
      tempstrga "sm" = or
      tempstrga "sn" = or
      tempstrga "pf" = or
      tempstrga "pm" = or
      tempstrga "pn" = or
      tempstrga "pp" = or
        { tempstrga output:write:field }
        { warning:invalid }
      if$
    }
  if$
}

FUNCTION {output:write:verb} {
  duplicate$ empty$
    { pop$ pop$ }
    { 'tempstrga :=
      "\verb" swap$ wrap:braces * output:indent:field
      { tempstrga empty$ not }
        { "\verb " tempstrga #1 ctrl.maxline #8 - substring$ * output:indent:field
          tempstrga ctrl.maxline #7 - global.max$ substring$ 'tempstrga :=
        }
      while$
      "\endverb" output:indent:field }
  if$
}

FUNCTION {output:write:name:last} {
  templist tempctra "{ll}" format.name$
  duplicate$ 'tempstrga :=
  wrap:braces
  templist tempctra
  ctrl.terseinits
    { "{l{}}" format.name$ }
    { "{l.}"  format.name$
      duplicate$ tempstrga "." * =
        { duplicate$ text.length$ #1 - text.prefix$ }
        'skip$
      if$
    }
  if$
  wrap:braces *
}

FUNCTION {output:write:name:first} {
  templist tempctra "{ff}" format.name$
  duplicate$ 'tempstrga :=
  wrap:braces
  templist tempctra
  ctrl.terseinits
    { "{f{}}" format.name$ }
    { "{f.}"  format.name$
      duplicate$ tempstrga "." * =
        { duplicate$ text.length$ #1 - text.prefix$ }
        'skip$
      if$
    }
  if$
  wrap:braces *
}

FUNCTION {output:write:name:prefix} {
  templist tempctra "{vv}" format.name$
  duplicate$ 'tempstrga :=
  duplicate$ duplicate$ text.length$ duplicate$ substring$ "'" =
    { #1 'tempctrc := }
    { #0 'tempctrc := }
  if$
  wrap:braces
  templist tempctra
  ctrl.terseinits
    { "{v{}}" format.name$ }
    { "{v.}"  format.name$
      tempctrc
        { duplicate$ text.length$ #1 - text.prefix$ "'" * }
        { duplicate$ tempstrga "." * =
            { duplicate$ text.length$ #1 - text.prefix$ }
            'skip$
          if$
        }
      if$
    }
  if$
  wrap:braces *
}

FUNCTION {output:write:name:suffix} {
  templist tempctra "{jj}" format.name$
  duplicate$ 'tempstrga :=
  wrap:braces
  templist tempctra
  ctrl.terseinits
    { "{j{}}" format.name$ }
    { "{j.}"  format.name$
      duplicate$ tempstrga "." * =
        { duplicate$ text.length$ #1 - text.prefix$ }
        'skip$
      if$
    }
  if$
  wrap:braces *
}

FUNCTION {output:write:name} {
  duplicate$ empty$
    { pop$ pop$ }
    { 'templist :=
      'tempstrga :=
      #1 'tempctra :=
      templist num.names$ 'tempctrb :=
      templist andothers
        { tempctrb #1 - 'tempctrb :=
          "more" tempstrga * #1 output:write:bool
        }
        'skip$
      if$
      "\name" tempstrga wrap:braces *
      tempctrb int.to.str$ wrap:braces *
      "{%" * output:indent:field
      { tempctrb #0 > }
        { "{" output:write:name:last   * "%"  * output:indent:subfield
          " " output:write:name:first  * "%"  * output:indent:subfield
          " " output:write:name:prefix * "%"  * output:indent:subfield
          " " output:write:name:suffix * "}%" * output:indent:subfield
          tempctra #1 + 'tempctra :=
          tempctrb #1 - 'tempctrb :=
        }
      while$
      "}" output:indent:field
    }
  if$
}

FUNCTION {output:write:list} {
  duplicate$ empty$
    { pop$ pop$ }
    { 'templist :=
      'tempstrga :=
      templist num.names$ 'tempctra :=
      templist andothers
        { tempctra #1 - 'tempctra :=
          "more" tempstrga * #1 output:write:bool
        }
        'skip$
      if$
      "\list" tempstrga wrap:braces *
      tempctra int.to.str$ wrap:braces *
      "{%" * output:indent:field
      #1 'tempctra :=
      #1 'tempctrb :=
      { templist normalize tempctrb global.max$ substring$ num.names$ #0 > }
        { templist tempctrb #5 substring$
          duplicate$ " AND " =
          swap$      " and " =
          or
            { templist tempctra tempctrb tempctra - substring$
              wrap:braces "%" * output:indent:subfield
              tempctrb #5 + duplicate$
              'tempctra :=
              'tempctrb :=
            }
            { tempctrb #1 + 'tempctrb := }
          if$
        }
      while$
      templist tempctra global.max$ substring$
      duplicate$ "others" =
        { pop$ }
        { wrap:braces "%" * output:indent:subfield }
      if$
      "}" output:indent:field
    }
  if$
}

FUNCTION {output:specials} {
  entryset empty$
    'skip$
    { ctrl:set
        { "\set"   }
	{ "\inset" }
      if$
      entryset wrap:braces * output:indent:field 
    }
  if$
  xref empty$
    'skip$
    { "\xref" xref wrap:braces * output:indent:field }
  if$
  keywords empty$
    'skip$
    { "\keyw" keywords wrap:braces * output:indent:field }
  if$
  "entrysubtype"    entrysubtype    output:write:field
  "crossref"        crossref        output:write:field
  "execute"         execute         output:write:field
  "namehash"        namehash        output:write:string
  "fullhash"        fullhash        output:write:string
  "gender"          gender          output:write:gender
  "shorthand"       shorthand       output:write:field
  shorthand empty$
    { label }
    { shorthand }
  if$
  "label"           swap$           output:write:field
  "labelalpha"      labelalpha      output:write:field
  "extraalpha"      extraalpha      output:write:field
  "labelyear"       extrayear       output:write:field
  "sortinit" fullhash #1 #1 substring$ "u" change.case$ output:write:field
  singletitle
    { "singletitle" #1 output:write:bool }
    'skip$
  if$
  ctrl.uniquename
    { "uniquename" uniquename output:write:count }
    'skip$
  if$
}

FUNCTION {output:names} {
  "author"          author          output:write:name
  "shortauthor"     shortauthor     output:write:name
  "bookauthor"      bookauthor      output:write:name
  "editor"          editor          output:write:name
  "shorteditor"     shorteditor     output:write:name
  "redactor"        redactor        output:write:name
  "translator"      translator      output:write:name
  "annotator"       annotator       output:write:name
  "commentator"     commentator     output:write:name
  "introduction"    introduction    output:write:name
  "foreword"        foreword        output:write:name
  "afterword"       afterword       output:write:name
  "holder"          holder          output:write:name
  "namea"           namea           output:write:name
  "nameb"           nameb           output:write:name
  "namec"           namec           output:write:name
  "authortype"      authortype      output:write:field
  "editortype"      editortype      output:write:field
  "nameatype"       nameatype       output:write:field
  "namebtype"       namebtype       output:write:field
  "namectype"       namectype       output:write:field
}

FUNCTION {output:lists} {
  "language"        language        output:write:list
  "organization"    organization    output:write:list
  "origlocation"    origlocation    output:write:list
  "origpublisher"   origpublisher   output:write:list
  "publisher"       publisher       output:write:list
  "lista"           lista           output:write:list
  "listb"           listb           output:write:list
  "listc"           listc           output:write:list
  "listd"           listd           output:write:list
  "liste"           liste           output:write:list
  "listf"           listf           output:write:list
}

FUNCTION {output:fields.pt1} {
  "abstract"        abstract        output:write:multi
  "addendum"        addendum        output:write:field
  "bookpagination"  bookpagination  output:write:field
  "booksubtitle"    booksubtitle    output:write:field
  "booktitleaddon"  booktitleaddon  output:write:field
  "booktitle"       booktitle       output:write:field
  "chapter"         chapter         output:write:field
  "day"             date.day        output:write:number
  "doi"             doi             output:write:verb
  "edition"         edition         output:write:field
  "eid"             eid             output:write:field
  "eprint"          eprint          output:write:verb
  "eprinttype"      eprinttype      output:write:field
  "eventtitle"      eventtitle      output:write:field
  "howpublished"    howpublished    output:write:field
  "hyphenation"     hyphenation     output:write:field
  "indexsorttitle"  indexsorttitle  output:write:field
  "indextitle"      indextitle      output:write:field
  "isan"            isan            output:write:field
  "isbn"            isbn            output:write:field
}

FUNCTION {output:fields.pt2} {
  "ismn"            ismn            output:write:field
  "isrn"            isrn            output:write:field
  "issn"            issn            output:write:field
  "issue"           issue           output:write:field
  "issuesubtitle"   issuesubtitle   output:write:field
  "issuetitle"      issuetitle      output:write:field
  "iswc"            iswc            output:write:field
  "journalsubtitle" journalsubtitle output:write:field
  "library"         library         output:write:field
  "mainsubtitle"    mainsubtitle    output:write:field
  "maintitleaddon"  maintitleaddon  output:write:field
  "maintitle"       maintitle       output:write:field
  "month"           date.month      output:write:number
  "nameaddon"       nameaddon       output:write:field
  "note"            note            output:write:field
  "number"          number          output:write:field
  "origlanguage"    origlanguage    output:write:field
  "origtitle"       origtitle       output:write:field
  "origyear"        origyear        output:write:range
  "pages"           pages           output:write:range
}

FUNCTION {output:fields.pt3} {
  "pagetotal"       pagetotal       output:write:range
  "pagination"      pagination      output:write:field
  "part"            part            output:write:range
  "reprinttitle"    reprinttitle    output:write:field
  "series"          series          output:write:field
  "shorthandintro"  shorthandintro  output:write:field
  "shortjournal"    shortjournal    output:write:field
  "shortseries"     shortseries     output:write:field
  "shorttitle"      shorttitle      output:write:field
  "subtitle"        subtitle        output:write:field
  "titleaddon"      titleaddon      output:write:field
  "title"           title           output:write:field
  "urlday"          urldate.day     output:write:number
  "urlmonth"        urldate.month   output:write:number
  "url"             url             output:write:verb
  "urlyear"         urldate.year    output:write:number
  "venue"           venue           output:write:field
  "version"         version         output:write:field
  "volumes"         volumes         output:write:field
  "volume"          volume          output:write:field
}

FUNCTION {output:fields.pt4} {
  "year"            date.year       output:write:range
  "usera"           usera           output:write:field
  "userb"           userb           output:write:field
  "userc"           userc           output:write:field
  "userd"           userd           output:write:field
  "usere"           usere           output:write:field
  "userf"           userf           output:write:field
  "verba"           verba           output:write:verb
  "verbb"           verbb           output:write:verb
  "verbc"           verbc           output:write:verb
}

FUNCTION {output:warning} {
  warningmsg empty$
    'skip$
    { "\warn" warningmsg wrap:braces * output:indent:field }
  if$
}

FUNCTION {output:compat.pt1} {
  "location" location
  duplicate$ empty$
    { pop$ address }
    { address empty$
        'skip$
        { "address" "location" warning:alias }
      if$
    }
  if$
  output:write:list
  "institution" institution
  duplicate$ empty$
    { pop$ school }
    { school empty$
        'skip$
        { "school" "institution" warning:alias }
      if$
    }
  if$
  output:write:list
  "file" file
  duplicate$ empty$
    { pop$ pdf }
    { pdf empty$
        'skip$
        { "pdf" "file" warning:alias }
      if$
    }
  if$
  output:write:verb
  "sortkey" sortkey
  duplicate$ empty$
    { pop$ key }
    { key empty$
        'skip$
        { "key" "sortkey" warning:alias }
      if$
    }
  if$
  output:write:field
}

FUNCTION {output:compat.pt2} {
  "type" type
  duplicate$ empty$
    { type$ "patent"        =
      type$ "techreport"    = or
      type$ "phdthesis"     = or
        { pop$ type$ }
        { type$ "mastersthesis" =
            { pop$ "mathesis" }
            'skip$
          if$
        }
      if$
    }
    'skip$
  if$
  output:write:field
  "journaltitle" journaltitle
  duplicate$ empty$
    { pop$ journal }
    { journal empty$
        'skip$
        { "journal" "journaltitle" warning:alias }
      if$
    }
  if$
  output:write:field
  "annotation" annotation
  duplicate$ empty$
    { pop$ annote }
    { annote empty$
        'skip$
        { "annote" "annotation" warning:alias }
      if$
    }
  if$
  output:write:multi
}

FUNCTION {output:debug} {
  "% sort.key$ = " sort.key$ * maxline write$ newline$
  sort.year empty$
    'skip$
    { "% sort.year = " sort.year * maxline write$ newline$ }
  if$
  sort.alph empty$
    'skip$
    { "% sort.alph = " sort.alph * maxline write$ newline$ }
  if$
}

FUNCTION {output:validate} {
  title empty$
    { "Missing field " "title" enquote * warning }
    'skip$
  if$
}

FUNCTION {output:entry} {
  'tempstrga :=
  newline$
  ctrl.debug
    { output:debug }
    'skip$
  if$
  "\entry"
  push:cite wrap:braces *
  tempstrga wrap:braces *
  entryoptions wrap:braces *
  write$ newline$
  output:validate
  output:names
  output:lists
  output:compat.pt1
  output:compat.pt2
  output:specials
  output:fields.pt1
  output:fields.pt2
  output:fields.pt3
  output:fields.pt4
  output:warning
  "\endentry" write$ newline$
}

FUNCTION {control}        { skip$ }
FUNCTION {set}            { type$ output:entry }

FUNCTION {article}        { type$ output:entry }
FUNCTION {booklet}        { type$ output:entry }
FUNCTION {book}           { type$ output:entry }
FUNCTION {collection}     { type$ output:entry }
FUNCTION {inbook}         { type$ output:entry }
FUNCTION {incollection}   { type$ output:entry }
FUNCTION {inproceedings}  { type$ output:entry }
FUNCTION {manual}         { type$ output:entry }
FUNCTION {misc}           { type$ output:entry }
FUNCTION {online}         { type$ output:entry }
FUNCTION {patent}         { type$ output:entry }
FUNCTION {periodical}     { type$ output:entry }
FUNCTION {proceedings}    { type$ output:entry }
FUNCTION {report}         { type$ output:entry }
FUNCTION {thesis}         { type$ output:entry }
FUNCTION {unpublished}    { type$ output:entry }

FUNCTION {artwork}        { type$ output:entry }
FUNCTION {audio}          { type$ output:entry }
FUNCTION {commentary}     { type$ output:entry }
FUNCTION {image}          { type$ output:entry }
FUNCTION {inreference}    { type$ output:entry }
FUNCTION {jurisdiction}   { type$ output:entry }
FUNCTION {legal}          { type$ output:entry }
FUNCTION {legislation}    { type$ output:entry }
FUNCTION {letter}         { type$ output:entry }
FUNCTION {movie}          { type$ output:entry }
FUNCTION {music}          { type$ output:entry }
FUNCTION {performance}    { type$ output:entry }
FUNCTION {reference}      { type$ output:entry }
FUNCTION {review}         { type$ output:entry }
FUNCTION {software}       { type$ output:entry }
FUNCTION {standard}       { type$ output:entry }
FUNCTION {suppbook}       { type$ output:entry }
FUNCTION {suppcollection} { type$ output:entry }
FUNCTION {suppperiodical} { type$ output:entry }
FUNCTION {video}          { type$ output:entry }

FUNCTION {customa}        { type$ output:entry }
FUNCTION {customb}        { type$ output:entry }
FUNCTION {customc}        { type$ output:entry }
FUNCTION {customd}        { type$ output:entry }
FUNCTION {custome}        { type$ output:entry }
FUNCTION {customf}        { type$ output:entry }

FUNCTION {conference}     { "inproceedings" output:entry }
FUNCTION {electronic}     { "online"        output:entry }
FUNCTION {mastersthesis}  { "thesis"        output:entry }
FUNCTION {other}          { "misc"          output:entry }
FUNCTION {phdthesis}      { "thesis"        output:entry }
FUNCTION {techreport}     { "report"        output:entry }
FUNCTION {www}            { "online"        output:entry }
FUNCTION {default.type}   { "misc"          output:entry }

% -------------------------------------------------------------------
% Input
% -------------------------------------------------------------------

FUNCTION {input:control:parse} {
  'tempstrga :=
  "" 'tempstrgb :=
  #1 'tempctra  :=
  { tempstrga empty$ not
    tempctra and }
    { tempstrga #1 #1 substring$ ":" =
        { #0 'tempctra := }
        { tempstrgb tempstrga #1 #1 substring$ * 'tempstrgb := }
      if$
      tempstrga #2 global.max$ substring$ 'tempstrga :=
    }
  while$
  tempstrga
  tempstrgb
}

FUNCTION {input:control:options} {
  input:control:parse str.to.int
}

FUNCTION {input:control:version} {
  input:control:parse
  "$Revision: 0.8b $"
  #12 entry.max$ substring$
  #-3 entry.max$ substring$
  'tempstrga :=
  duplicate$ tempstrga =
    { pop$ }
    { "Version mismatch: biblatex.bst=" tempstrga *
      ", biblatex.sty=" * swap$ * warning$
      pop$ "" }
  if$
}

FUNCTION {input:control} {
  ctrl-options empty$
    'skip$
    { ctrl-options input:control:version
      duplicate$ empty$
        { pop$ }
	{ input:control:options 'ctrl.debug :=
	  input:control:options 'ctrl.bibtex8 :=
	  input:control:options 'ctrl.terseinits :=
	  input:control:options 'ctrl.useprefix :=
	  input:control:options 'ctrl.useauthor :=
	  input:control:options 'ctrl.useeditor :=
	  input:control:options 'ctrl.usetranslator :=
	  input:control:options 'ctrl.labelalpha :=
	  input:control:options 'ctrl.labelyear :=
	  input:control:options 'ctrl.singletitle :=
	  input:control:options 'ctrl.uniquename :=
	  input:control:options 'ctrl.sorting :=
	  input:control:options 'ctrl.sortlos :=
	  input:control:options 'ctrl.maxnames :=
	  input:control:options 'ctrl.minnames :=
	  input:control:options 'ctrl.maxline :=
	  'ctrl.alphaothers :=
	}
      if$
      ctrl.maxline #49 <
        { #49 'ctrl.maxline := }
        { ctrl.maxline #79 >
            { #79 'ctrl.maxline := }
            'skip$
	  if$
	}
      if$
    }
  if$
}

FUNCTION {input:options:add} {
  entryoptions empty$
    'skip$
    { entryoptions ", " * 'entryoptions := }
  if$
  entryoptions swap$ * 'entryoptions :=
  duplicate$ empty$
    { pop$ }
    { "=" swap$ * entryoptions swap$ * 'entryoptions := }
  if$
}

FUNCTION {input:options:known} {
  duplicate$ empty$
    { tempstrgb input:options:add
      #1 }
    { duplicate$ "true" =
        { pop$ "" tempstrgb input:options:add 
	  #1 }
	{ duplicate$ tempstrgb input:options:add
	  bol.to.int 
	}
      if$
    }
  if$
}

FUNCTION {input:options:parse} {
  'tempstrgb :=
  tempstrgb "useprefix" =
    { input:options:known 'useprefix := }
    { tempstrgb "useauthor" =
	{ input:options:known 'useauthor := }
	{ tempstrgb "useeditor" =
	    { input:options:known 'useeditor := }
	    { tempstrgb "usetranslator" =
		{ input:options:known 'usetranslator := }
		{ tempstrgb "skipbib" =
		    { input:options:known 'skipbib := }
		    { tempstrgb "skiplos" =
			{ input:options:known 'skiplos := }
			{ tempstrgb "skiplab" =
			    { input:options:known 'skiplab := }
			    { tempstrgb "dataonly" = 
				{ input:options:known 
				  duplicate$ 'skipbib :=
				  duplicate$ 'skiplos := 
			                     'skiplab := 
				}
				{ tempstrgb input:options:add }
			      if$
			    }
			  if$
			}
		      if$
		    }
		  if$
		}
	      if$
	    }
	  if$
	}
      if$
    }
  if$
}

FUNCTION {input:options:extract} {
  'tempstrgb :=
  #1 'tempctrb :=
  { tempstrgb text.length$ #0 > }
    { tempstrgb tempctrb #1 substring$ "=" =
        { tempstrgb tempctrb #1 + global.max$ substring$
          tempstrgb #1 tempctrb #1 - substring$
          input:options:parse
          "" 'tempstrgb :=
        }
        { tempstrgb text.length$ tempctrb =
            { "" tempstrgb input:options:parse
              "" 'tempstrgb :=
            }
            { tempctrb #1 + 'tempctrb := }
          if$
        }
      if$
    }
  while$
}

FUNCTION {input:options} {
  options 'tempstrga :=
  #1 'tempctra :=
  { tempstrga text.length$ #0 > }
    { tempstrga tempctra #1 substring$ "," =
        { tempstrga #1 tempctra #1 - substring$ input:options:extract
          tempctra #1 + 'tempctra :=
          { tempstrga tempctra #1 substring$ " " =
            tempctra tempstrga text.length$ > not
            and
          }
            { tempctra #1 + 'tempctra := }
          while$
          tempstrga tempctra global.max$ substring$ 'tempstrga :=
          #1 'tempctra :=
        }
        { tempstrga text.length$ tempctra =
            { tempstrga input:options:extract
              "" 'tempstrga :=
            }
            { tempctra #1 + 'tempctra := }
          if$
        }
      if$
    }
  while$
}

FUNCTION {input:date:assign} {
  swap$ duplicate$ empty$
    { pop$ pop$ }
    { swap$ := }
  if$
}

FUNCTION {input:date:padded} {
  swap$ duplicate$ empty$
    { pop$ pop$ }
    { #2 pad.number swap$ := }
  if$
}

FUNCTION {input:date:fields} {
  day      'date.day      input:date:padded
  month    'date.month    input:date:padded
  year     'date.year     input:date:assign
  urlday   'urldate.day   input:date:padded
  urlmonth 'urldate.month input:date:padded
  urlyear  'urldate.year  input:date:assign
}

FUNCTION {input:date:parse} {
  date number.prefix number.prefix number.prefix pop$
  'date.day      input:date:padded
  'date.month    input:date:padded
  'date.year     input:date:assign
  urldate number.prefix number.prefix number.prefix pop$
  'urldate.day   input:date:padded
  'urldate.month input:date:padded
  'urldate.year  input:date:assign
}

FUNCTION {input:date:parse:url} {
  date number.prefix number.prefix number.prefix pop$
  'date.day      input:date:padded
  'date.month    input:date:padded
  'date.year     input:date:assign
  urldate number.prefix number.prefix number.prefix pop$
  'urldate.day   input:date:padded
  'urldate.month input:date:padded
  'urldate.year  input:date:assign
}

FUNCTION {input:iterate} {
  ctrl:control
    { input:control }
    { citecount #1 + 'citecount :=
      citecount int.to.str$ #9 pad.number 'sortkey.nosort :=
      ctrl.useprefix 'useprefix :=
      ctrl.useauthor 'useauthor :=
      ctrl.useeditor 'useeditor :=
      ctrl.usetranslator 'usetranslator :=
      ctrl.singletitle
        { #1 'singletitle := }
        'skip$
      if$
      options empty$
        'skip$
        { input:options }
      if$
      ctrl:set entryset empty$ or
	'skip$
	{ #1 'skipbib :=
	  #1 'skiplos := 
	  #1 'skiplab := 
	}
      if$
      date empty$
        'skip$
        { input:date:parse }
      if$
      urldate empty$
        'skip$
        { input:date:parse:url }
      if$
      input:date:fields
    }
  if$
}

READ

EXECUTE {initialize}

ITERATE {input:iterate}

% -------------------------------------------------------------------
% Generate labels
% -------------------------------------------------------------------

FUNCTION {makelabel:name:format} {
  'templist :=
  #1 'tempctra :=
  templist num.names$ 'tempctrb :=
  templist andothers
    { tempctrb #1 - 'tempctrb := }
    'skip$
  if$
  tempctrb ctrl.maxnames >
    { ctrl.minnames 'tempctrc := }
    { ctrl.maxnames 'tempctrc := }
  if$
  ""
  { duplicate$ text.length$ entry.max$ #50 - <
    tempctra tempctrc > not and
    tempctrb #0 > and
    }
    { useprefix
        { templist tempctra "{vv}" format.name$
          duplicate$ empty$
            { pop$ "" }
            { "u" change.case$ "t" change.case$ 
              subsubdelimiter * }
          if$
        }
        { "" }
      if$
      templist tempctra "{ll}" format.name$ *
      tempctra #1 >
        { subdelimiter swap$ * }
        'skip$
      if$
      *
      tempctra #1 + 'tempctra :=
      tempctrb #1 - 'tempctrb :=
    }
  while$
  templist andothers
  tempctrb #0 >
  or
    { subdelimiter * "zzzz" * }
    'skip$
  if$
}

FUNCTION {makelabel:name:uniq} {
  duplicate$ num.names$ #1 =
    { #1
      "{ll}{" subsubdelimiter *
      "f}{" subsubdelimiter * *
      "v}{" subsubdelimiter * *
      "j}" *
      format.name$
    }
    { pop$ "" }
  if$
}

FUNCTION {makelabel:name:full} {
  duplicate$ num.names$ #1 =
    { #1
      "{ll}{" subsubdelimiter *
      "ff}{" subsubdelimiter * *
      "vv}{" subsubdelimiter * *
      "jj}" *
      format.name$
    }
    { pop$ "" }
  if$
}

FUNCTION {makelabel:alpha:format} {
  duplicate$ empty$
    { pop$ "" }
    { 'templist :=
      #1 'tempctra :=
      templist andothers
        { templist num.names$ #1 - 'tempctrb := }
        { templist num.names$ 'tempctrb := }
      if$
      tempctrb ctrl.maxnames >
        { ctrl.minnames 'tempctrb := }
        'skip$
      if$
      tempctrb #1 >
        { ""
          { tempctrb #0 > }
            { templist tempctra "{l{}}" format.name$ *
              tempctra #1 + 'tempctra :=
              tempctrb #1 - 'tempctrb :=
            }
          while$
        }
        { templist #1 "{l{}}" format.name$ }
      if$
      duplicate$ text.length$ #2 <
        { pop$
          useprefix
            { templist #1 "{v{}}" format.name$ #2 text.prefix$
              templist #1 "{ll}"  format.name$ *
            }
            { templist #1 "{ll}" format.name$ }
          if$
          #3 text.prefix$
        }
        'skip$
      if$
    }
  if$
  templist num.names$ ctrl.maxnames >
  templist andothers
  or
    { ctrl.alphaothers * }
    'skip$
  if$
}

FUNCTION {makelabel:alpha:year} {
  date.year normalize
  #1  #4 substring$
  #-1 #2 substring$
}

FUNCTION {makelabel:hash:title} {
  purify$ truncate
  duplicate$
  #2 entry.max$ substring$ 'tempstrga :=
  #1 #1 substring$
  { tempstrga text.length$ #0 > }
    { tempstrga #1 #1 substring$ " " =
        { 
          { tempstrga #1 #1 substring$ " " = }
            { tempstrga #2 entry.max$ substring$ 'tempstrga := }
          while$
          tempstrga #1 #1 substring$ *
        }
        'skip$
      if$
      tempstrga #2 entry.max$ substring$ 'tempstrga :=
    }
  while$
}

FUNCTION {makelabel:hash:format} {
  'templist :=
  #1 'tempctra :=
  templist num.names$ 'tempctrb :=
  templist andothers
    { tempctrb #1 - 'tempctrb := }
    'skip$
  if$
  tempctrb ctrl.maxnames >
    { ctrl.minnames 'tempctrc := }
    { ctrl.maxnames 'tempctrc := }
  if$
  ""
  { tempctra tempctrc > not
    tempctrb #0 >
    and }
    { templist tempctra
      useprefix
	{ "{v{}}{l{}}{j{}}{f{}}" }
	{ "{l{}}{j{}}{f{}}{v{}}" }
      if$
      format.name$ purify$ *
      tempctra #1 + 'tempctra :=
      tempctrb #1 - 'tempctrb :=
    }
  while$
  templist andothers
  tempctrb #0 >
  or
    { "+" * }
    'skip$
  if$
}

FUNCTION {makelabel:hash:format:full} {
  'templist :=
  #1 'tempctra :=
  templist num.names$ 'tempctrb :=
  templist andothers
    { tempctrb #1 - 'tempctrb := }
    'skip$
  if$
  ""
  { tempctrb #0 > }
    { templist tempctra
      useprefix
	{ "{v{}}{l{}}{j{}}{f{}}" }
	{ "{l{}}{j{}}{f{}}{v{}}" }
      if$
      format.name$ purify$ *
      tempctra #1 + 'tempctra :=
      tempctrb #1 - 'tempctrb :=
    }
  while$
  templist andothers
    { "+" * }
    'skip$
  if$
}

FUNCTION {makelabel:ctrl:alpha} {
  ctrl:labelalpha
    { label empty$
        { push:cite normalize #1 #3 substring$
          "u" change.case$ "t" change.case$ }
        { label makelabel:alpha:year * }
      if$
    }
    { "" }
  if$
}

FUNCTION {makelabel:ctrl:alpha:format} {
  ctrl:labelalpha
    { label empty$
        { makelabel:alpha:format }
        { pop$ label }
      if$
      makelabel:alpha:year *
    }
    { pop$ "" }
  if$
}

FUNCTION {makelabel:label} {
  push:shortname empty$
    { push:sorttitle duplicate$ 'label.name :=
      duplicate$ empty$
        { pop$ push:cite normalize }
        { makelabel:hash:title }
      if$
      'namehash :=
      makelabel:ctrl:alpha 'labelalpha :=
    }
    { push:shortname
      duplicate$ makelabel:name:format 'label.name :=
      duplicate$ makelabel:hash:format 'namehash :=
      ctrl.uniquename
        { duplicate$ makelabel:name:uniq 'label.uniq := }
        'skip$
      if$
      makelabel:ctrl:alpha:format 'labelalpha :=
    }
  if$
  push:fullname empty$
    { push:sorttitle duplicate$ empty$
        { pop$ push:cite normalize }
        { makelabel:hash:title }
      if$
    }
    { push:fullname makelabel:hash:format:full }
  if$
  'fullhash :=
}

FUNCTION {makelabel:label:uniq} {
  uniquename #0 =
    'skip$
    { uniquename #1 =
        { label.uniq 'label.name := }
        { push:shortname makelabel:name:full 'label.name := }
      if$
    }
  if$
}

% -------------------------------------------------------------------
% Sort labels
% -------------------------------------------------------------------

FUNCTION {labelsort:label} {
  sortkey:init:label
  makelabel:label
}

FUNCTION {labelsort:main} {
  ctrl:skiplab not
  ctrl.singletitle ctrl.labelyear or
  and
    { label.name normalize delimiter *
      sortkey.year * delimiter *
      push:presort * delimiter *
      sortkey empty$
        { sortkey.name * delimiter * sortkey.title }
        { sortkey }
      if$
      *
      truncate
    }
    { "" }
  if$
  duplicate$
  'sort.key$ :=
  'sort.year :=
}

FUNCTION {labelsort:alph} {
  ctrl:skiplab not
  ctrl:labelalpha
  and
    { labelalpha normalize delimiter *
      push:presort * delimiter *
      sortkey empty$
        { ctrl.sorting #10 >
          ctrl.sorting #20 <
          and
            { ctrl.sorting #10 - }
            { #2 }
          if$
          sortkey:main:string
        }
        { sortkey }
      if$
      *
      truncate
    }
    { "" }
  if$
  duplicate$
  'sort.key$ :=
  'sort.alph :=
}

FUNCTION {labelsort:hash} {
  ctrl:control
    'skip$
    { namehash normalize delimiter *
      push:shortname duplicate$ empty$
        { pop$ "zzzz" * }
        { sortkey:name:format normalize * }
      if$
      truncate 'sort.key$ :=
    }
  if$
}

FUNCTION {labelsort:hash:full} {
  ctrl:control
    'skip$
    { fullhash normalize delimiter *
      push:shortname duplicate$ empty$
        { pop$ "zzzz" * }
        { sortkey:name:format normalize * }
      if$
      truncate 'sort.key$ :=
    }
  if$
}

% -------------------------------------------------------------------

FUNCTION {labelsort:init} {
  "" 'last.name  :=
  "" 'last.uniq  :=
  "" 'last.year  :=
  "" 'last.alph  :=
  "" 'last.hash  :=
  "" 'last.extra :=
  #0 'last.uniq.num  :=
  #1 'last.extra.num :=
}

FUNCTION {labelsort:main:init} {
  "" 'last.name  :=
}

FUNCTION {labelsort:hash:init} {
  "" 'last.name :=
  #1 'last.extra.num :=
}

FUNCTION {labelsort:hash:iterate} {
  ctrl:control
    'skip$
    { namehash last.hash =
        { push:shortname:hash:trunc last.name =
            'skip$
            { last.extra.num #1 + 'last.extra.num := }
          if$
          last.extra.num int.to.str$ 'labelhash :=
        }
        { #1  'last.extra.num :=
          "1" 'labelhash  :=
        }
      if$
      namehash 'last.hash :=
      push:shortname:hash:trunc 'last.name :=
    }
  if$
}

FUNCTION {labelsort:hash:reverse} {
  ctrl:control
    'skip$
    { push:shortname:hash:trunc last.name =
        { last.extra "1" =
            { "1" 'labelhash := }
            'skip$
          if$
        }
        { last.extra "2" =
            { "1" 'labelhash := }
            'skip$
          if$
        }
      if$
      labelhash 'last.extra :=
      push:shortname:hash:trunc 'last.name  :=
      namehash labelhash * 'namehash :=
    }
  if$
}

FUNCTION {labelsort:hash:full:iterate} {
  ctrl:control
    'skip$
    { fullhash last.hash =
        { push:shortname:hash:full last.name =
            'skip$
            { last.extra.num #1 + 'last.extra.num := }
          if$
          last.extra.num int.to.str$ 'labelhash :=
        }
        { #1  'last.extra.num :=
          "1" 'labelhash  :=
        }
      if$
      fullhash 'last.hash :=
      push:shortname:hash:full 'last.name :=
    }
  if$
}

FUNCTION {labelsort:hash:full:reverse} {
  ctrl:control
    'skip$
    { push:shortname:hash:full last.name =
        { last.extra "1" =
            { "1" 'labelhash := }
            'skip$
          if$
        }
        { last.extra "2" =
            { "1" 'labelhash := }
            'skip$
          if$
        }
      if$
      labelhash 'last.extra :=
      push:shortname:hash:full 'last.name  :=
      fullhash labelhash * 'fullhash :=
    }
  if$
}

FUNCTION {labelsort:uniquename} {
  ctrl:skiplab not
  ctrl.uniquename
  and
    { push:shortname num.names$ #1 >
        'skip$
        { push:shortname:hash:trunc last.hash =
            { last.uniq.num 'uniquename := }
            { label.name last.name =
                { label.uniq last.uniq =
                  ctrl.uniquename #1 =
                  and
                    { #2 'uniquename := }
                    { #1 'uniquename := }
                  if$
                }
                'skip$
              if$
            }
          if$
          label.name 'last.name :=
          label.uniq 'last.uniq :=
          uniquename 'last.uniq.num :=
          push:shortname:hash:trunc 'last.hash :=
        }
      if$
    }
    'skip$
  if$
}

FUNCTION {labelsort:main:singletitle} {
  ctrl.singletitle
    { label.name last.name =
        { #0 'singletitle := }
        'skip$
      if$
      label.name 'last.name :=
    }
    'skip$
  if$
}

FUNCTION {labelsort:main:year:iterate} {
  ctrl.labelyear
    { label.name
      date.year empty$
         'skip$
         { " " * date.year * }
      if$
      'label.year :=
      label.year last.year =
        { last.extra.num #1 + 'last.extra.num :=
          last.extra.num int.to.str$ 'extrayear :=
        }
        { #1 'last.extra.num :=
          "" 'extrayear :=
          label.year 'last.year :=
        }
      if$
    }
    'skip$
  if$
}

FUNCTION {labelsort:main:year:reverse} {
  ctrl.labelyear
    { last.extra "2" =
        { "1" 'extrayear := }
        'skip$
      if$
      extrayear 'last.extra :=
    }
    'skip$
  if$
}

FUNCTION {labelsort:main:iterate} {
  ctrl:skiplab
    'skip$
    { labelsort:main:singletitle
      labelsort:main:year:iterate
    }
  if$
}

FUNCTION {labelsort:main:reverse} {
  ctrl:skiplab
    'skip$
    { labelsort:main:singletitle
      labelsort:main:year:reverse
    }
  if$
}

FUNCTION {labelsort:alph:iterate} {
  ctrl:skiplab not
  ctrl:labelalpha
  and
    { labelalpha last.alph =
        { last.extra.num #1 + 'last.extra.num :=
          last.extra.num int.to.str$ 'extraalpha :=
        }
        { #1 'last.extra.num :=
          "" 'extraalpha :=
        }
      if$
      labelalpha 'last.alph :=
    }
    'skip$
  if$
}

FUNCTION {labelsort:alph:reverse} {
  ctrl:skiplab not
  ctrl:labelalpha
  and
    { last.extra "2" =
        { "1" 'extraalpha := }
        'skip$
      if$
      extraalpha 'last.extra :=
      labelalpha empty$
	'skip$
	{ extraalpha empty$
	    { labelalpha normalize 'sortkey.alpha := }
	    { labelalpha normalize extraalpha #4 pad.number * 'sortkey.alpha := }
	  if$
	}
      if$
    }
    'skip$
  if$
}

ITERATE {labelsort:label}

EXECUTE {labelsort:init}

ITERATE {labelsort:hash}

SORT

EXECUTE {labelsort:hash:init}

ITERATE {labelsort:hash:iterate}

EXECUTE {labelsort:hash:init}

REVERSE {labelsort:hash:reverse}

EXECUTE {labelsort:init}

ITERATE {labelsort:hash:full}

SORT

EXECUTE {labelsort:hash:init}

ITERATE {labelsort:hash:full:iterate}

EXECUTE {labelsort:hash:init}

REVERSE {labelsort:hash:full:reverse}

EXECUTE {labelsort:init}

ITERATE {labelsort:main}

SORT

ITERATE {labelsort:uniquename}

EXECUTE {labelsort:init}

REVERSE {labelsort:uniquename}

ITERATE {makelabel:label:uniq}

EXECUTE {labelsort:init}

EXECUTE {labelsort:main:init}

ITERATE {labelsort:main:iterate}

EXECUTE {labelsort:main:init}

REVERSE {labelsort:main:reverse}

EXECUTE {labelsort:init}

ITERATE {labelsort:alph}

SORT

ITERATE {labelsort:alph:iterate}

REVERSE {labelsort:alph:reverse}

% -------------------------------------------------------------------
% Sort bibliography, write .bbl file
% -------------------------------------------------------------------

FUNCTION {mainsort} {
  ctrl:control
    { "" }
    { sortkey:main }
  if$
  'sort.key$ :=
}

FUNCTION {lossort} {
  ctrl.sortlos
    { shorthand empty$
      ctrl:skiplos or
        { "" }
        { shorthand }
      if$
      truncate
      'sort.key$ :=
    }
    'skip$
  if$
}

ITERATE {mainsort}

SORT

FUNCTION {output:main:begin} {
  "% $ biblatex auxiliary file $"                               write$ newline$
  "% $ biblatex version " "$Revision: 0.8b $"
  #12 entry.max$ substring$ #-3 entry.max$ substring$ * " $" *  write$ newline$
  "% Do not modify the above lines!"                            write$ newline$
  "%"                                                           write$ newline$
  "% This is an auxiliary file used by the 'biblatex' package." write$ newline$
  "% This file may safely be deleted. It will be recreated as"  write$ newline$
  "% required."                                                 write$ newline$
  "%"                                                           write$ newline$
  "\begingroup"                                                 write$ newline$
  "\makeatletter"                                               write$ newline$
  "\@ifundefined{ver@biblatex.sty}"                             write$ newline$
  "  {\@latex@error"                                            write$ newline$
  "     {Missing 'biblatex' package}"                           write$ newline$
  "     {The bibliography requires the 'biblatex' package.}"    write$ newline$
  "      \aftergroup\endinput}"                                 write$ newline$
  "  {}"                                                        write$ newline$
  "\endgroup"                                                   write$ newline$
}

FUNCTION {output:main:preamble} {
  preamble$ empty$
    'skip$
    { newline$
      "\preamble{%" write$ newline$
      preamble$ write$ newline$
      "}" write$ newline$
    }
  if$
}

FUNCTION {output:main:end} {
  newline$
  "\endinput" write$ newline$
}

FUNCTION {output:los:begin} {
  newline$
  "\lossort" write$ newline$
}

FUNCTION {output:los:iterate} {
  shorthand empty$
  ctrl:skiplos or
    'skip$
    { "  \key{" push:cite * "}" * write$ newline$ }
  if$
}

FUNCTION {output:los:end} {
  "\endlossort" write$ newline$
}


EXECUTE {output:main:begin}

EXECUTE {output:main:preamble}

ITERATE {call.type$}

ITERATE {lossort}

SORT

EXECUTE {output:los:begin}

ITERATE {output:los:iterate}

EXECUTE {output:los:end}

EXECUTE {output:main:end}

% -------------------------------------------------------------------
