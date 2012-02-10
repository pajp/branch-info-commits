#!/usr/bin/env ruby

require 'digest/sha1'
require 'zlib'
require 'fileutils'

ourheader = "x-working-branch"

f = File.open(".git/HEAD")
currentbranch = f.readline.split(": ", 2)[1].split("/")[-1].chomp
f.close

puts "Current branch: #{currentbranch}"

headref=".git/refs/heads/#{currentbranch}"

f = File.open(headref, 'r')
head = f.read(40)
f.close

print "Reading commit #{head}\n"

commitpath = ".git/objects/#{head[0,2]}/#{head[2,38]}"

f = File.open(commitpath, 'r')
objectdata = Zlib::Inflate.inflate(f.read)
f.close

objectparts = objectdata.split("\000", 2)
commitdata = objectparts[1].split("\n\n", 2);


commitdatahdrs = commitdata[0].split("\n")
match = false
i=0
commitdatahdrs.each { |hdr|
    if hdr.match(/^#{ourheader}/) 
        value = hdr.split(" ", 2)[1]
        if value.eql?(currentbranch)
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

objectparts[1] = commitdata.join("\n\n")
objectparts[0] = "commit #{objectparts[1].size}"
objectdata = objectparts.join("\000")

newcommithash = Digest::SHA1.hexdigest(objectdata)
newcommitpath = ".git/objects/#{newcommithash[0,2]}/#{newcommithash[2,38]}"

FileUtils.mkdir_p(File.dirname(newcommitpath))
f = File.open(newcommitpath, 'w')
f.write Zlib::Deflate.deflate(objectdata)
f.close

# change head to point to our new commit
f = File.open(headref, 'w')
f.write(newcommithash)
f.close

print "New head of branch #{currentbranch} is #{newcommithash}\n"

