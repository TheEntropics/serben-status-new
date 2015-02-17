Ping.create!([
	             {
		             up: true,
		             ping: 15,
		             created_at: Time.now-5.minutes
	             },
	             {
		             up: true,
		             ping: 10,
		             created_at: Time.now-4.minutes
	             },
	             {
		             up: false,
		             ping: 15,
		             created_at: Time.now-3.minutes
	             },
	             {
		             up: true,
		             ping: 6,
		             created_at: Time.now-2.minutes
	             },
	             {
		             up: true,
		             ping: 12,
		             created_at: Time.now-1.minutes
	             },
	             {
		             up: true,
		             ping: 15,
		             created_at: Time.now
	             },
             ])

Service.create!(
	[
		{
			service: 'minecraft',
			status: true
		},
		{
			service: 'openarena',
			status: false
		},
		{
			service: 'cod4',
			status: true
		}
	])

SysInfo.create!([
	                {
		                cpu: 1.20,
		                ram: 0.55,
		                created_at: 5.minutes.ago,
		                uptime: 2.hours.ago
	                },
	                {
		                cpu: 1.80,
		                ram: 0.50,
		                created_at: 4.minutes.ago,
		                uptime: 2.hours.ago
	                },
	                {
		                cpu: 1.60,
		                ram: 0.55,
		                created_at: 3.minutes.ago,
		                uptime: 2.hours.ago
	                },
	                {
		                cpu: 0.90,
		                ram: 0.50,
		                created_at: 2.minutes.ago,
		                uptime: 2.hours.ago
	                },
	                {
		                cpu: 0.85,
		                ram: 0.25,
		                created_at: 1.minutes.ago,
		                uptime: 2.hours.ago
	                },
	                {
		                cpu: 0.70,
		                ram: 0.20,
		                created_at: Time.now,
		                uptime: 2.hours.ago
	                }
                ])
Log.create!([{
	             title: 'Fatal error',
	             level: 0,
	             message: 'A <strong>fatal</strong> error occurred'
             }])