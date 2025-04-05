import std.stdio;
import dotenv;

import binance;

void main()
{
	Env.load;
	auto api_key = Env["api_key"];
	auto secret_key = Env["secret_key"];
	
	auto bn = new Binance(api_key, secret_key);
	auto res = bn
				.general
				.exchange_info
				.symbol("BTCUSDT")
				.perform;

	writeln(res);
}
