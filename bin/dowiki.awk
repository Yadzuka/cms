#!/usr/bin/awk -f
#
# EustroWIKI rendering tool prototype
# (c) Alex V Eustrop 2019
# (c) EustroSoft.org 2019
#
# LICENSE: BALES, MIT, ISC
#
# developed for http://qr.qxyz.ru
#

BEGIN{
p=0;
ul=0;
h=0;
is_table=0;
line_num=0;
errno=0;
#default_p_align="justify"
CGI_GETFILE="/cgi-bin/getfile.cgi";
QR_REQUEST="q=123&p=123"
process_input_stream();
}

END{
close_all();
if(h!=0) { close_tag("div"); print "<!-- END -->"; } # accordion
}

# read all input stream and print out html-formatted text
function process_input_stream(	line, full_line)
{
 line="#";
 errno=1; # global var
 while(errno==1)
 {
  full_line="";
  # read next line
  errno=getline line;
  if(errno!=1) break;
  line_num++;
  #print "<br>" line_num ":";
  #comment line
  if(line ~/^#/){continue;}
  # empty line
  if(line ~ /^[ \t]*$/){
   if(ul==1){close_tag("ul");ul=0;};
   if(p==1){close_tag("p");p=0;};
   print "";
   continue;
  }
  
  # header line
  if( line ~ /^=/){
   #if(ul==1){close_tag("ul");ul=0;};
   #if(p==1){close_tag("p");p=0;};
   close_all();
   #h=length($1);
   if(h!=0) {close_tag("div"); }
   h=match(line,/[^=]/);
   sub(/^[=]*[ \t]*/,"",line);
   sub(/[=]*[ \t]*$/,"",line);
   printf("<h%i class='accordion'>%s</h%i>\n",h,render_line(line),h);
   print "<div class='panel'>";
   continue;
  }
  
  # list item line
  if( line ~ /^\*/){
   full_line=read_full_line(line);
   sub(/^\*/,"",full_line);
   if(p==1){close_tag("p");p=0;};
   if(ul==0){ print "<ul>"; ul=1; }
   print "<li>" render_line(full_line);
   continue;
  }
  # table
  if( line ~ /^;./){
   if(ul==1){close_tag("ul");ul=0;};
   if(p==1){close_tag("p");p=0;};
   full_line=read_full_line(line);
   if(is_table==0){
    is_table=1;
    c_count=0;
    # process first row
    c_count=process_cellarray_from_line(full_line);
    print_new_table_from_cellarray(c_count);
    continue;
   }
    # process non-first row
    process_cellarray_from_line(full_line);
    print_tab_row_from_cellarray(c_count);
    continue;
  } #/table
  if( line ~ /^----/){
   close_all();
   print "<hr>"
   continue;
  }
  if( line ~ /^<=/){
   close_all();
   if(line ~/^<=c/) {align="center";}
   if(line ~/^<=l/) {align="left";}
   if(line ~/^<=r/) {align="right";}
   if(line ~/^<=j/) {align="justify";}
   sub(/^<=[a-z]*/,"",line);
   open_tag_p(align); p=1;
  }

  if(is_table==1){ close_all(); }
  if(p==0){ open_tag("p"); p=1; }
  print_line(line);
 } #/while(errno)
 if(errno==-1){
  print "<div class='error'>file not found</div>";
  return;
 }
}

function process_cellarray_from_line(line,	i, c_count, sep)
{
sep=substr(line,2,1);
line=substr(line,3);
gsub("\n"," ",line);
#cellarray=""; # clear it (cellarray is global)
c_count=split(line,cellarray,sep);
return(c_count);
}
function print_new_table_from_cellarray(c_count,	i, sep)
{
open_tag("table");
open_tag("tbody");
open_tag("tr");
for(i=1;i<=c_count;i++)
{
 cellhide[i]=0;
 if(cellarray[i] ~ /^=/)
 {
  if(cellarray[i] ~ /^=#/)
  {
   cellarray[i]=substr(cellarray[i],3);
   cellhide[i]=1;
   continue;
  }
  else
  {
   cellarray[i]=substr(cellarray[i],2);
  }
 }
 print_th_field(cellarray[i]);
}
close_tag("tr");

}

function print_tab_row_from_cellarray(c_count,        i)
{
    open_tag("tr");
    for(i=1;i<=c_count;i++)
    {
     if(!cellhide[i]){
      if(cellarray[i] ~ /^=/){
       cellarray[i]=substr(cellarray[i],2);
       print_th_field(cellarray[i]);
      }
      else { print_td_field(cellarray[i]); }
     }
    }
    close_tag("tr");
}

function print_td_field(line)
{
    open_tag("td");
     print_line(line);
    close_tag("td");
}
function print_th_field(line)
{
    open_tag("th");
     print_line(line);
    close_tag("th");
}

function read_full_line(line, full_line)
{
full_line="";
while(errno==1)
{
 if(line ~ /\\n[ \t]*$/){
  sub(/\\n[ \t]*$/,"\n",line);
  full_line=full_line line; 
  errno = getline line; line_num++;
  continue;
 }
 if(line ~ /\\[ \t]*$/){
  #print line_num ":" line "<br>";
  sub(/\\[ \t]*$/,"",line);
  full_line=full_line line; 
  errno = getline line; line_num++;
  continue;
 }
 full_line=full_line line; 
 break;
}
return(full_line);
}

function open_tag_p(align)
{
 if(align==""){align=default_p_align; }
 if(align==""){ print "<p>"; }
 else{ print "<p align='" align "'>"; }
}
function open_tag(tag)
{
print "<" tag ">";
}

function close_tag(tag)
{
print "</" tag ">";
}

function render_line(line){
 line=escapeHTML(line);
 line=wikify(line);
 line=render_wiki_markup(line);
 return(line);
}

function print_line(line){
 print render_line(line);
}

function wikify(line){
 #gsub("http://[a-z\._]*","[[&|&]]",line);
 gsub("EustroSoft","[[http://eustrosoft.org|&|Эпоха ренесcанса начинаяется здесь]]",line);
 return(line);
}
function render_wiki_markup(line, num_repl)
{
 line=render_span_markup(line,"\\*\\*","<b>","</b>");
 line=render_span_markup(line,"__","<u>","</u>");
 line=render_link_markup(line);
 return(line);
}

function render_link_markup(line,	count,start, start_http, end, restline, linepart, linkparts, title, filename)
{
 restline=line;
 line="";
 while(restline != "")
 {
  start=match(restline,"\\[\\[");
  url_regexp="(http://|https://|tel:|mailto:|telnet:|ssh:)[_a-zA-Z0-9\.@+\(\)\-\/]*"

  #start_http=match(restline,"(http://|https://|tel:|mailto:|telnet:|ssh:)[a-z\.@+\(\)\-]*");
  start_http=match(restline,url_regexp);
  if( start_http > 0 && (start_http < start || start == 0))
  {
   #sub("(http://|https://|tel:|mailto:|telnet:|ssh:)[a-z\.@]*","[[&|&]]",restline);
   sub(url_regexp,"[[&|&]]",restline);
   start=start_http;
  }
  if(start>0){
   linepart=substr(restline,1,start-1);
   restline=substr(restline,start);
   line=line linepart;
   end=match(restline,"]]");
   if(end>0) {
     linepart=substr(restline,1,end+1);
     restline=substr(restline,end+2);
    }
   else {linepart=restline "]]"; restline="";}
   linepart=substr(linepart,3,length(linepart)-4);
   count=split(linepart,linkparts,"|");
   if(count>=2)
   {
    title="";
    if(count>=3){ title= " title='" linkparts[3] "'"; }
    linepart=linkparts[2];
    if(linkparts[1] ~/^(http|https|tel|mailto|ssh|telnet):/)
     { linepart="<a href='"linkparts[1] "'" title ">" linkparts[2] "</a>"; }
    if(linkparts[1] ~/^file:/)
     {
      filename=substr(linkparts[1],6);
      linepart="<a href='" CGI_GETFILE "?file=" filename "&" QR_REQUEST "'" title ">" linkparts[2] "</a>"; }
    if(linkparts[1] ~/^img:/)
     {
      filename=substr(linkparts[1],6);
      linepart="<img src='" filename "'" title "/>" ; }
   }
   #if(count==1){ linepart=linepart }

   line=line "<u>" linepart "</u>";
  }
  else{line=line restline; restline="";}
 }
 return(line);
}

function render_span_markup(line,re,o_tag,c_tag,	num_repl)
{
 num_repl=1;
 while(num_repl)
 {
  num_repl=sub(re,o_tag,line);
  if(num_repl){
   num_repl=sub(re,c_tag,line);
   if(!num_repl) { line=line c_tag; }
  }
 }
 return(line);
}

print_line_t(line){
if(t==0){print "<table><tbody>"; t=1;}
}

function close_all()
{
   if(is_table==1){
      close_tag("tbody");
      close_tag("table");
      is_table=0;
   };
   if(ul==1){close_tag("ul");ul=0;};
   if(p==1){close_tag("p");p=0;};
}

function print_h(level,data)
{
 printf("<h%i>%s</h%i>\n",level,data,level);
}


#!/usr/bin/awk -f
#!/usr/local/bin/gawk -f
# mave.ru project
# Decode/encode GET parameters
# (c) Eustrop 2006
# History
# 2006/07/05 start
# 2006/07/06 mostly done - 154 lines
#

#escape metacharacters
function escapeHTML(s)
{
gsub("&","\\&and;",s);
gsub("<","\\&lt;",s);
gsub(">","\\&gt;",s);
gsub("'","\\&apos;",s);
gsub("\"","\\&quot;",s);
return(s);
}

# extract query string from REQUEST_URI
#function extract_qs(req_uri, n) # skipped...

#
# Encode string for using it as var name or parameter for GET request
# Usage:
#   print encode_uri_var("To be, or not to be?..\n1000% for free\nI & me.");
function encode_uri_var(var)
{
gsub("%","%25",var);
gsub(/\+/,"%2B",var);
gsub(" ","+",var);
gsub("&","%26",var);
gsub(/\?/,"%3F",var);
gsub("=","%3D",var);
gsub("\t","%09",var);
gsub("\n","%0A",var);
gsub("\r","%0D",var);

return(var);
} #/encode_uri_var

# decode '%' and '+' encoded query string
# !USE it for splitted parts of query string only, due to %26 -> '&'
# transformation
# Usage: print decode_qs_pp("A+%A1");
# function decode_qs_pp( qs,    i, c, n, h, is_pecent)

#
# convert two-characters hexadecimal string to single character
# via ASCII table
# usage: print hex2char("0A");

function hex2char(hex,	hex_up, digit, digit2,len,i, result){
 hex_up =toupper(hex);
 len=length(hex_up);
 if(len != 2) return("");
 split(hex_up,digit,"");
 i=0;
 result=0;
 while(++i<=2)
 {
  digit2 = (digit[i] + 0);
  if(digit2 == 0 )
  {
   if(digit[i] == "0" ) digit2 = 0;
   else if(digit[i] == "A" ) digit2 = 10;
   else if(digit[i] == "B" ) digit2 = 11;
   else if(digit[i] == "C" ) digit2 = 12;
   else if(digit[i] == "D" ) digit2 = 13;
   else if(digit[i] == "E" ) digit2 = 14;
   else if(digit[i] == "F" ) digit2 = 15;
  }
  result = result +  digit2*(16^(len-i));
 } #while
 #if(result == 0) return("\\0");
 if(result == 0) return(" ");
 return(sprintf("%c",result));
} #/hex2char

