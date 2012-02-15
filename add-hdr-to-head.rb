#!/usr/bin/env ruby

# The majority of this code was written on tram number 8 in Helsinki

require 'digest/sha1'
require 'zlib'
require 'fileutils'

ourheader = "x-working-branch"

# figure out current working branch
head = ""

f = File.open(".git/HEAD")
row = f.readline.chomp
if row.match(/^ref: /)
    currentbranch = row.split(": ", 2)[1].split("/")[-1]
else
    currentbranch = "detached: #{row}"
    head = row
end

f.close

puts "Current branch: #{currentbranch}"

if head.eql?("")
    headref=".git/refs/heads/#{currentbranch}"

    f = File.open(headref, 'r')
    head = f.read.chomp
    f.close
end

print "Reading commit #{head}\n"

f = IO.popen("git cat-file commit #{head}", "r");
commitdata = f.read.split("\n\n", 2);
f.close

commitdatahdrs = commitdata[0].split("\n")

match = false
i=0

# parse commit metadata, modify our header if it's found,
# otherwise add it
commitdatahdrs.each { |hdr|
    if hdr.match(/^#{ourheader}/) 
        value = hdr.split(" ", 2)[1]
        if value.eql?(currentbranch)
            # no reason to create a new commit if the current one already contains the information
            print "Head commit already contains #{ourheader}: #{currentbranch}\nNot changing anything.\n"
            exit 0
        end
        
        commitdatahdrs[i] = "#{ourheader} #{currentbranch}"
        match = true
    end
    i += 1
}

commitdata[0] = commitdatahdrs.join("\n")

if !match
    commitdata[0] += "\n#{ourheader} #{currentbranch}"
end

# create a new commit object and write it to disk
f = IO.popen("git hash-object -w --stdin -t commit", "w+");
f.puts commitdata.join("\n\n")
f.close_write
newcommithash = f.readline.chomp
f.close


if headref
    reffile = headref
    print "New head of branch #{currentbranch} is #{newcommithash}\n"
else
    reffile = ".git/HEAD"
    print "New detached HEAD is #{newcommithash}\n"
end

# change head to point to our new commit
f = File.open(reffile, 'w')
f.write(newcommithash)
f.close


