udp-broadcast-relay-redux: main.c
	$(CC) $(CFLAGS) -g main.c -o udp-broadcast-relay-redux

clean:
	rm -f udp-broadcast-relay-redux
