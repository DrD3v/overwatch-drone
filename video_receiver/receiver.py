import socket
import subprocess

client_socket = socket.socket()
client_socket.connect(('192.168.20.19', 9999))

# Make a file-like object out of the connection
connection = client_socket.makefile('wb')
try:
    # Run a viewer with an appropriate command line. Uncomment the mplayer
    # version if you would prefer to use mplayer instead of VLC
    cmdline = ["C:\Program Files (x86)\VideoLAN\VLC\vlc.exe", '--demux', 'h264', '-']
    #cmdline = ['mplayer', '-fps', '31', '-cache', '1024', '-']
    player = subprocess.Popen(cmdline, stdin=subprocess.PIPE)
    while True:
        # Repeatedly read 1k of data from the connection and write it to
        # the media player's stdin
        data = connection.read(1024)
        if data:
            player.stdin.write(data)
finally:
    connection.close()
