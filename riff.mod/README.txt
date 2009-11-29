
IMPORTANT: To install this module using git, create joe.mod in your mod folder, then use the git clone URL to download the files.


This module allows you to manipulate RIFF files in blitz. The RIFF file format is a container format, like XML, used by other formats, including WAVE and AVI. Like XML it is hierarchical, but unlike XML it is a binary format, not a text format, and everything is stored as efficiently as possible, so that the header for each chunk of data (including the file itself) consists only of 8 bytes, 4 for a tag, another 4 for the size of the chunk. List chunks, which contain other chunks, have a further 4 bytes for the list ID.

The module is OO, but there are a few non-OO functions for those who like them. Currently, when reading, the entire file is read into memory at once, so you can't stream with the module, and similarly files are simply overwritten when saving a RIFF file. These might be a problem if you're working with large files, but for a simple custom file format (for example, a tile map) the module is sufficient.
