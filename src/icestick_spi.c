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

	if (ftdi_write_data (&ftdic, data, n) != n) {
		fprintf (stderr, "ftdi_write_data buffer error\n");
		exit (1);
	}
}

void
spi_xfer (uint8_t *xbuf, uint8_t *rbuf, int n)
{
	int count_arg = n - 1;

	send_byte (0x31);
	send_byte (count_arg);
	send_byte (count_arg >> 8);

	if (ftdi_write_data (&ftdic, xbuf, n) != n) {
		fprintf (stderr, "spi_xfer write error\n");
		exit (1);
	}

	if (ftdi_read_data (&ftdic, rbuf, n) != n) {
		fprintf (stderr, "spi_xfer read error\n");
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

	if (ftdi_setflowctrl(&ftdic, SIO_DISABLE_FLOW_CTRL) < 0) {
		fprintf (stderr, "ftdi_setflowctrl error\n");
		exit (1);
	}


	if (ftdi_set_bitmode (&ftdic, 0xff, BITMODE_MPSSE) < 0) {
		fprintf (stderr, "ftdi_set_bitmode error\n");
		exit(1);
	}

	double bit_rate = 2e6;
	double reference_clock = 60e6;
	int divisor = (reference_clock / 2 / bit_rate) - 1;

	send_byte (0x8a); // disable divide by 5

	send_byte (0x86); // set divisor
	send_byte (divisor);
	send_byte (divisor >> 8);

	// bits 3..0 are: CK MOSI MISO SSEL
	send_byte (0x80);
	send_byte (0x00);  // CK=0 MOSI=0 SSEL=0
	send_byte (0x0b); // CK MOSI SSEL are outputs
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
		val = strtol (argv[optind++], NULL, 0);

	if (optind != argc)
		usage ();

	icestick_spi_init ();

	if (0) {
		send_spi (&val, 1);
	} else {
		uint8_t rbuf[100];
		rbuf[0] = 0x55;
		spi_xfer (&val, rbuf, 1);
		printf ("%x\n", rbuf[0]);
	}

	return 0;
}
