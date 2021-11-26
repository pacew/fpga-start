#include <stdio.h>

#include <ftdi.h>


static struct ftdi_context ftdic;

void
send_byte (uint8_t data)
{
	if (ftdi_write_data (&ftdic, &data, 1) != 1) {
		fprintf (stderr, "ftdi_write_data error\n");
		exit (1);
	}
}

void
send_spi (uint8_t *data, int n)
{
	send_byte (0x11);
	send_byte (n-1);
	send_byte ((n-1) >> 8);

	if (ftdi_write_data(&ftdic, data, n) != n) {
		fprintf (stderr, "ftdi_write_data buffer error\n");
		exit (1);
	}
}

void
icestick_spi_init (void)
{
	ftdi_init (&ftdic);
	ftdi_set_interface (&ftdic, INTERFACE_B);

	if (ftdi_usb_open (&ftdic, 0x0403, 0x6010)) {
		fprintf(stderr, "ftdi_usb_open error\n");
		exit (1);
	}

	if (ftdi_usb_reset (&ftdic)) {
		fprintf (stderr, "ftdi_usb_reset error\n");
		exit (1);
	}

	if (ftdi_usb_purge_buffers (&ftdic)) {
		fprintf (stderr, "ftdi_usb_purge_buffers error\n");
		exit (1);
	}

	/* doing this disable resets things if they were in a bad state */
	if (ftdi_disable_bitbang (&ftdic) < 0) {
		fprintf (stderr, "ftdi_disable_bitbang error\n");
		exit (1);
	}

	if (ftdi_set_bitmode (&ftdic, 0xff, BITMODE_MPSSE) < 0) {
		fprintf (stderr, "ftdi_set_bitmode error\n");
		exit(1);
	}

	// enable clock divide by 5
	send_byte (0x8b);

	// set 6 MHz clock
	send_byte (0x86);
	send_byte (0x02);   // 1 or 2 MHz ?
	send_byte (0x00);

	// configure output bits
	send_byte (0x80);
	send_byte (0x01);
	send_byte (0x0B);
}

void
usage (void)
{
	fprintf (stderr, "usage: icestick_spi [0|1]\n");
	exit (1);
}

int
main(int argc, char **argv)
{
	int c;
	uint8_t val;

	while ((c = getopt (argc, argv, "")) != EOF) {
		switch (c) {
		default:
			usage ();
		}
	}

	if (optind < argc)
		val = atoi (argv[optind++]);

	if (optind != argc)
		usage ();

	icestick_spi_init ();

	send_spi(&val, 1);

	return 0;
}
