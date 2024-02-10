// FinishingWasher-v1.0

// [r, z]
profile = [
	[2.5, 0  ],
	[2.5, 2.5],
	[4.5, 4.5],
	[6.5, 4.5],
	[8.5, 2.5],
	[8.5, 0  ]
];

rotate_extrude($fn=72) {
	polygon(profile);
}
