version-to-files-svn-pre-commit-hook
====================================

This is simple script for subversion. With this script every time you commit your code, you can write current version number to selected file or set of files. And all - in automatic way. So you will no longer forget put actual version number in your project.

This script is written in vbscript and so is working on every Windows OS version without any additional libraries and/or software.

For setting this script:

1. just [download it](https://raw.github.com/msangel/version-to-files-svn-pre-commit-hook/master/version_to_file_pre_commit.vbs)
2. configure SVN(this is for TortoiseSVN, but other programs for SVN shuld have similar config in options)
    1. Find your repository in explorer
    2. In context menu of repository folder select TortoiseSVN/Settings
    3. In settings window select "Hook Scripts"
    ![example settings](http://cs606523.vk.me/v606523044/1c23/nAcUZkPYbNg.jpg "example settings")
    
    4. Select "Add", and fill all with this data: 
        1. Hook Type: Pre-Commit Hook
        2. Working Copy Path: any (do not used in our script, I just point to root svn directory)
        3. Command Line To Execute: "wscript < path_to_cript >" (This is my Command Line To Execute: `wscript D:\home\source_code\hooktest\version_to_file_pre_commit.vbs`)
        4. Check "Wait for the script to finish" and "Hide the script while running"
        ![example settings](http://cs606523.vk.me/v606523044/1c13/-Y8QyIsBxD0.jpg "example settings")
3. configure script
    1. Open script via text editor
    2. Assign to `pathToRootOfSVNRepo` path to your svn root folder
    3. Assign to `pathToWatchingDirectory` path, where you need to track changes
    4. Assign to `whereToWriteArr` array of files names, in what you need write version number
    ![example settings](http://cs606523.vk.me/v606523044/1c2c/Oa_YQ_9YG-s.jpg "example settings")
4. Save all and test it!

If you have any troubles with working with this script, I am always open for question. My e-mail is h6.msangel@gmail.com
    




