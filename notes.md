
## Introduction

Hello;

Thank you Arshak for the introduction.  I am Steven Pav.  
I will be talking to you today about 'backtests' and about all the 
different things that can go wrong with them, and about 
spotting these kinds of problems and maybe fixing them. 
I assume that nearly all of you are interested in systematic 
strategies. Whether you are trying to get into the business, or
have been running backtests for years, I hope you will get something
out of this talk.

## Who am I?

To give you some idea of my background, I am an applied mathematician
by training. I worked for almost 9 years at two small hedge funds here in
San Francisco as a 'quant', working in equities and volatility futures.
I spent my time writing and maintaining infrastructure for backtesting,
devising strategies and backtesting them, deploying strategies and 
debugging the entire process of deploying systematic strategies.
I have plied many ML and statistical techniques in the search for 
'alpha'.

When I started my career in the quant world, it was somewhat terrifying
to me, as a former academic, that there was nothing written about 
what we were doing. I am _not_ talking about the theory of 
price evolution or the theory of portfolio construction and risk evaluation
and so on; there are new papers on all that written every day. I am 
talking about the mechanics of writing, testing, validating and debugging
a backtesting simulator. At the time I could not find anything written
about it, and there were no open source libraries that helped in any way.
Now at least there is Zipline, which you will hear more about later today,
but at the time there was nothing, which is odd because many academic papers, 
for example about factor models, perform some kind of simulation of the value
of portfolios of equities.  So there are simulations in many of these papers,
but everyone rewrites that part themselves, from scratch. Which is what I did,
and what some of you will do. 

By the way, considering that academics do this all the time, and that the simulator
is not the main focus of many of these papers, you should suspect that many
academic papers that rely on implicit backtests are flawed in some way or
another, especially those which rely on lots of trading.

## Why backtest?

So why do people use backtests? Well, consider what it takes to find a 
profitable trading strategy. The hardest part probably is 
finding a way to predict future price movements. When I first started
out, I thought this was really the _only_ part of the problem. This
is the part you point all your fancy ML at, it is the sexy part of the 
problem.  But you also need to turn these predictions into trades. 
It is easy to sometimes lose sight of this, and think that because
you can predict the change in _nominal_ marks of some asset that you
are winning, but you need to go a little deeper than this. Many people
start out using price data from Yahoo or Google finance without
thinking about what an 'adjusted close' really is, whether you can
capture that price, and how you should actually turn your predictions into
orders.

To succeed you also need to control your exposure to certain risks,
for example, exposure to the broad market, exposure to developing
markets, or the tech industry, oil, and so on, either because you promised
this to investors, or you have no view on these factors or you think
you cannot predict them. 

You also need to estimate and control your trading costs, your market
impact, commissions, short financing and so on. These are the costs
associated with turning your predictions into profitable trades.

In theory, I guess you could estimate each of these effects separately,
but there are so many moving parts, it is hard to untangle them and
how they interplay, so instead you will want to simulate the whole
trading system. And this is a backtest. 
Do not get me wrong, you will need to validate all the parts of a 
backtesting system separately, but you use them together when backtesting
a strategy. 

Backtesting implies a _systematic_ strategy. By that I mean that execution
of the strategy relies on data, unfolds according to a recipe or algorithm,
and that you have the historical data required to simulate how the
strategy would have been executed in the past.

There are a few reasons you might backtest a strategy:

* You might backtest to estimate the risk and expected return of a strategy
so you can deploy the optimal amount of capital in it.
* You might backtest to decide whether a strategy should be productionized.
Many people deploy systematic strategies in a different language
than they perform R&D, so they need to be approved and rewritten, which has
a cost associated with it. 

## What do backtests do?

So what should a backtest do for you? By definition it should simulate
the environment in which you will execute your strategy. So it presents
to your strategy a point-in-time view of the data, and accepts orders.
It should then simulate the reactions of the world to your action,
the fills on your orders, commissions, market impact and so on. It should
also deal with corporate actions in a sane way: if you are holding a
stock which experiences a split or spinoff or merger, it should simulate
those, of course. But probably the most important part is that 
a backtest should provide some absolute guarantee of time safety.  
I will talk about this more, but 'time safety' means you are simulating
your strategy as it would actually be executed, instead of simulating
a time machine.

Writing a good backtesting environment requires a number of different 
skills. First, there is the software engineering aspect.  I always think
of a backtesting system as a tradeoff among three competing design
goals, which are absolute time safety, computational efficiency, and
developer brain damage. It is easy to create a system that achieves two of
these goals, but achieving all three is a real challenge.

A good backtesting system will require some domain knowledge: 
you need to understand that corporate actions happen, and you need to represent
them in your data and your system; 
you have to figure out what kinds of orders you want to support, how they
should be represented, how fill should be simulated, and so on. 
I first started out at a fund that had very little domain experience,
and we had a lot of trouble because of it. 
But there are some things that domain experts cannot tell you. I have
learned not to ask a trader "what should my market impact be?", 
partly because it is a silly question, like asking "how long is a string?", 
but also because traders generally do not have a very accurate estimate
of your impact, and will just tell you whatever.

Writing a good backtest system will also require great statistical powers:
you have to know how to represent and interpret the results; 
how to figure out the sensitivity of your results to the unknowns, and
how to avoid overfitting.

Lastly, you will also need good sleuthing abilities. 
When you are starting out you will probably have this experience: 
you backtest a new strategy, and it looks very promising. 
The first thing you need to figure out is "what new thing is broken in my backtests?" 
And this can be really hard because you will get tired of banging your head against the 
wall of the markets, 
and you backtested the strategy because you wanted it to work, 
and because _you_ wrote the simulator code and now have to find _your own_ error.

It is actually easier, of course, to debunk other peoples backtests, but
this gets you a reputation of being kind of a jerk, because nobody likes
being debunked. 

By the way, ML techniques are simply _great_ at finding errors in backtesting
systems. Consider genetic programming, which generates and tests new
trading strategies. This technology should be sold as a product for finding
errors in backtesters.

## Different kinds of backtests

I like to think of the different kinds of backtests as a pyramid. 
At the top you have the very high fidelity but slow backtests
that require more data and memory that you run not very often, 
and at the bottom you have the low fidelity, quick and dirty quasi-backtests 
that you run all the time. 
The idea is that a strategy that does not look good in a quick and dirty simulator
probably is not going to get better when you start overlaying more realistic
trade costs, so it is more efficient to quickly reject strategies which
have no predictive ability by using a fast test that has higher type I rate
but nearly the same power as the slower tests up the pyramid.

At the bottom of the pyramid you can think of really fast 
path-independent tests like just computing the correlation of your predictive
signal to the leading adjusted returns of the assets. You just need
to figure out how to aggregate correlation laterally across stocks and over
time.  This is path independent, though--it does not really discriminate between 
strategies based on how much trading they do. 

So at the next level up you probably have some kind of path-dependent simulator
that can at least charge you for commissions and some fixed proportion of
your dollar turnover for market impact. To deal with corporate actions and
actual cost commissions, you might want to have both 'adjusted' and unadjusted
prices fed into the simulator. And for efficiency your simulator probably
makes very strong assumptions about how you turn predictions into trades.
Remember that the correlation metric does this implicitly, but people will
have different ideas about how this should be done, so you might need to
have a few different simulators at this level, or some knobs to parametrize
how a signal is traded.

Depending on your assumptions that backtester might be scale independent,
meaning it gives you the same proportional results independently of whether
you are simulating a million or a billion dollars deployed. 
So at the next level up you might want a more nuanced model of market impact
which depends on the level of equity simulated. To do this you probably need to know
the volume traded and the liquidity of each asset, so these are some
extra data requirements, and you will need a model of market impact,
which will have some unknown and uncertain parameters in it.

At the top level you have a gold-plated 'capital-B' Backtester. From my
understanding, Zipline exists at this level. This backtester takes a 
callback function. It wakes up the callback at simulated points in time,
gives the historical data and positions to the callback, the callback
generates a trades list, the simulator simulates the fills, and
the process repeats. 
In theory you could deploy this callback in real trading, feeding
it real data and positions, and then really executing the trades that
are generated. I have done this, and I believe this is what Quantopian 
is aiming to do with Zipline.

I should note that it is fairly simple to write a first pass of this kind
of backtester. Your callback can batch recompute everything it needs
every time it is called, it could call an optimizer to generate a portfolio
from predicted returns, and so on. But you will quickly find this is insanely
inefficient. I should note the reason I am a zealot about efficiency
is that finding alpha is hard--most things you try will not work. Time is
a limited resource, so you will soon realize you need to streamline
this process. So you start making the tradeoff of developer sanity for
computational efficiency, or worse time-safety for efficiency.

## Garbatrage

Before I catalog some of the errors you will commit when writing and
using a backtester, I want to talk about 'garbatrage'.  Broadly defined
this is the name I use for a trading strategy that looks profitable in
simulations but only because of something broken in your simulations.
You are effectively 'arbing' your broken code.

Consider the development of systematic strategies from the viewpoint
of Bayes' Rule: 
constructing profitable trading strategies is very hard. Some people--very smart
and competent people--try for years to come up with strategies, and fail,
and give up. Some people, the Efficient Markets camp, believe it is
essentially impossible. So the prior probability that you will come up
with a profitable strategy is pretty low.

On the other hand, bugs are dime a dozen. A good programmer will 
write--and correct--several bugs a day. (Bad programmers write them, but
do not correct them.) Syntactic programming bugs 
just waste time, but semantic and logical bugs can lurk uncaught for a long 
time, and these will lead to garbatrage. This means that using backtests
to predict future returns may have a higher than nominal type I rate, or rather
the probability of a nice looking backtest given that the strategy is no good
might be rather high.

Using Bayes' Rule, you can estimate the _odds_ that you have found a good
strategy conditional on observing a good backtest. It is this equation here.
Let $A$ be the event that the strategy is good, $B$ be the event that the
backtest looks good. 
The conditional odds of a good backtest is the unconditional odds, which is like the background
rate, probably very small, maybe one in ten million, times the Bayes Factor
$\Lambda$, which you can assume is like one over the type one rate. So maybe
'ten x' or even smaller. So the posterior odds are like one in a million
maybe or worse.
By this kind of computation, you probably should conclude, if you see a good backtest,
that the backtest is broken or overfit, and not that you have found what thousands of others
have been looking for unsuccesfully over the last 50 years.
Keep this in mind particularly when you are looking at a new
strategy you just coded up, or using new backtesting code, or you have read
an academic paper or a whitepaper from a vendor: 
_when your backtest looks good, it is probably a bug._

I will give you some examples: a paper from 2012 on SSRN claimed that a
momentum strategy trading monthly on month-old data had an
annualized Sharpe of 3.5 and annualized returns of over 500%. 
Sounds great, right? The data are simple to gather, the strategy is easy
to execute, maybe about a week of work, and then you retire!
The paper was quickly removed after 
[appearing on CXO](http://feedproxy.google.com/~r/cxo/~3/R1PvB1jvcmU/).
Someone probably contacted the authors, and they found an error and
retracted.

Another example is the famous, but mostly uncontested paper from 2011
that claims that some latent indicator of 'calmness' from three day old 
tweets predicts the movement of the DJIA with sufficient accuracy
to give you an annualized Sharpe of around 9. With that kind of predictive
ability, you could lever up and easily get 2000 percent returns annually.
In maybe 7 years time _you would have all the money in the world._ 
The paper has been cited almost 2000 times in the literature and is
considered the seminal paper on social media sentiment trading, yet the
findings are based on only 15 days of market returns in December of 2008,
and should be considered very suspicious.

## Time Travel

Perhaps the most common error in testing strategies is what I call 'time travel',
also known as non-causality. Time travel is simulated use of information which
you could not have observed at that point in time to trade. It is a lot
easier to simulate than implement, though it would be very profitable.
It seems like such an obviously wrong thing to do, why do people do it? Why
does time travel happen? 

A few reasons:
  * I think it occurs often when people try to do quick and dirty tests using
off-the-shelf tools, and don't understand how they work. For example, 
you are in a hurry, you take a diff of log prices to get returns, 
you align with another time series of features, there are no syntax errors, 
you start taking correlations of signal to returns, and suddenly
you are time traveling. If you are going to spend some time working with
systematic strategies, you need to move beyond this workflow and start using
dedicated tools that avoid this kind of basic time travel.

Some other sources of time travel, and I will talk about these in turn, are:
+  Backfill and survivorship bias in data.
+  Representation of corporate actions.
+  Miscellaneous think-os.

## Survivorship and Backfill

Survivorship and backfill are two classic data errors in simulations, not just quantitative finance. 
As an example, suppose you were looking at fundamental data--the 'fundamental' value 
of an entire business like assets, liabilities, sales, cash flow, and so on.
Suppose there was a company that went out of business in 2008, but you
potentially would have bought or sold in 2005. If that company is not in your
data set at all because they do not exist in 2016, that is _survivorship bias_.
If you consider the average historical returns of companies which are in a dataset
of this kind, they will be biased upwards because underperformers have been eliminated.

Backfill bias is similar. Suppose it was hard for your data provider to
collect and digitize fundamental data, so they only did it for 'large'
companies, say those who were the top 1500 by market cap in any given quarter.
But then suppose that a client of the data provider called them up and asked
for historical data on `XYZ` corporation, which is large now, but was not in
the top 1500 in, say 2001. The data provider goes back and digitizes all the
fundamentals data for `XYZ` going back to their founding.  Now presence in your
dataset is biased by future information, or backfill bias.

It turns out you can test for this in your data, assuming you have a 
'gold standard' data set that really is point-in-time from which you
can construct your universe historically. Or you could just ask your
data provider, often they will confess they do this.

Another form of universe construction bias comes from how data providers
(or you) deal with mergers and spinoffs. Pretend for example you are
providing data to a fundamental trader who wants to analyze book value
today by looking at the last 3 years of a company's filings. If the company
had a merger in the last 3 years, maybe the trader just wants 
the fundamentals of the two companies weighted by cap, added together
and presented as one number. This is _not_ point-in-time time series,
and can have survivorship issues if the acquired company is dropped from
the data.

## Corporate Actions

This brings us to corporate actions. Corporate actions are splits, dividends,
mergers, spinoffs, issuance of warrants and rights and so on.  
Thinking back to the three design goals of a backtesting system,
representation of corporate actions often prioritizes computational efficiency
and developer ease-of-use, but, in my experience, might sacrifice time safety. 

Usually to deal with corporate actions, the adjusted prices of a company's
stock are represented as a single time series across time. In reality, they
should probably be branching backwards and forwards in time. For example, think
of the mess of representing Citigroup, which in recent history saw the merger
of Citicorp and Travelers Group, which had itself absorbed Salomon and Smith
Barney and so on, then spun off Travelers insurance business a few years later,
got involved in the subprime mess, nationalized, denationalized, and so on.
It reminds one of the Ship of Theseus, where only the ticker has stayed the 
same, although sometimes the ticker changes too. 
You start to wonder whether a single time series representation even makes sense.

Often for convenience, adjusted prices are 'back adjusted' meaning the
current price of the adjusted series matches the actual current price.
This is presumably for the convenience of traders who live in the present,
but for those of us who need to simulate point-in-time trading, there is an
issue. Regular splits and dividends cause backwards adjusted closes to be
lower than actual closes earlier in history, as in this plot of Microsoft's
actual and backwards-adjusted daily close prices. If you constructed a
portfolio which was, across its universe, inversely proportional to 
adjusted close, you could capture this time-travel 'arb'. Note that in
this case the quality of your returns degrade over the simulated
history as the real and adjusted prices converge. So that is a way to test
for this kind of time travel in your simulations.

## The ML Hacker Trap

This is another great error. Like all the bugs I have listed here, I have
written this one, and I have seen others write it as well. The problem is as
follows: for any kind of predictive model, you need to align leading returns
with the observable features. So for example suppose you observe some signal
after the close every day, and will trade the next trading day in the
early morning, and flatten your position by the close, for some reason.
So you are trying to predict the next days returns from the signal today.
So for example, the price movements over Thursday have to be aligned to the 
signal observed on Wednesday. This is perfectly natural. 

(Flip slide)

Now pretend you are training your model after the signal is observed on a
Tuesday. The ML Hacker Trap occurs when you accidentally use the aligned
returns from the next Wednesday in the model which is timestamped to 
that Tuesday. If you then simulate _using_ that model on Tuesday, you just
time traveled Wednesday's returns. This error is pure ML catnip, because
_the more often you retrain your model, the better it gets_. It's usually
also accompanied by a short training window, which is justified by some
excuse for downweighting older observations for 'freshness'.

Again, this is just out and out time travel. And it occurs if you
write the training and testing cross-validation yourself as a one-off
instead of using a framework that prevents time travel. This is just
another instance of the tradeoff between efficiency, ease of
use and time safety.

## Broken Fill Simulation

Backtests require some simulation of the fill of your orders. When you
submit an order in the real world, it might not get filled, or it might
be partially filled, or it might be filled at a price that is far from 
your arrival price.  If you want to implement some kind of a stop loss order, 
it might have to chase the market, and maybe not get entirely filled. 
If you are working in the low frequency world and simulating with hourly or daily
price bars, it is not clear how you should simulate these possibilities
given the data you are using.

Moreover, there is the well-recognized phenomenon of 'market impact',
which says that submitting an order changes the balance of supply and demand 
for an asset and should lead to a worse fill price for your order on average.
Of course, the larger your order, the greater the imbalance, and the worse
your price is, but it is not precisely known how the price impact is related to the
order size. There are models for this, for example Almgren's model, 
and they are based on some theory, but they will have unknown parameters. 

Fitting the parameters using data is a tricky business. In the Almgren
study, they looked at the prices at which lots of orders were filled. But
you are only observing one history, you do not see what the prices would
have been if those orders were not submitted. Moreover, these parameter
fitting exercises often ignore factors which we know affect the price
of a stock. For example, Almgren's study ignores the comovement of the
broad market. When I performed a similar study, I found that market beta
was the _leading factor_ in explaining the movement of assets, and it
affected the parameters we fit in our slippage model. But then there is a
slippery slope--which factors do you include in your model, and then
there is the harder question of how you perform a simulation with such
an elaborate model.

At the very least, you should recognize that fill simulation adds a cloud
of uncertainty around your results. The more often your strategy trades,
the larger this cloud should be. Most of the analysis tools you will use,
however, want to treat your backtests as a time series of returns, and so
now you have to figure out how to overlay this uncertainty.

## Overfitting?

At last we come to overfitting. Overfitting is typically the first
suspect when quant funds have an 'out-of-sample experience'. It is the
most well known backtesting error. People have drawn cartoons about it.

## Overfitting

But what is overfitting? In my mind there are two related problems
that could be considered overfitting, and they are mostly procedural errors,
unlike the computational errors I have been discussing.

First there is the problem of having a biased estimate of
out-of-sample performance of a strategy based on the in-sample evidence.
This might sound benign, but in reality, you might be trading a strategy
with negative expected returns, which would be bad. The other kind of
overfitting is where you have selected a suboptimal strategy because
the class of strategies you chose from was too large. 

If you think about it you may see that these two problems actually are
distinct.  You could have actually selected the optimal strategy, but still have
a biased estimate of its performance; conversely you could have a
procedure for unbiased estimation, but still select a suboptimal
strategy. 
Yet there is something paradoxical about these two problems, and it feels like
they _should_ be unified, and probably they can be. 

## Biased Estimates

To me, the first problem sounds a lot like 'estimation after selection'. That
set phrase signifies a specific problem in statistics which has been considered
by a few authors since the 60's. 

So for example, suppose you somehow generated 1000 'random' strategies using
some random strategy generator, then you pick the best one by maximizing
the Sharpe ratio on the data available to you up to now. How do you estimate
the real Sharpe of that strategy? You can make this problem more elaborate
by allowing the generation procedure to 'hill-climb' in-sample, or otherwise
make the search procedure 'path dependent'. You quickly get a very
hairy technical problem. 

And while there are technical approaches to this technical problem, 
and other tests for 'data snooping' which are often prescribed to fight this
kind of overfitting, I am not convinced that this is entirely a technical problem 
to be solved with better math and algorithms. I feel that overfitting of this form often
comes from procedural sloppiness: for example, trying a thousand strategies,
but not keeping track of how many you tried, or how they were related to each
other and so on.

Informally people lean heavily on some division of the data into 'in-sample' and
'out-of-sample' periods. For example, maybe you will hear of people who perform
model selection using only returns data from Mondays, Wednesdays and Fridays.
Then to estimate performance, they use data only from Tuesdays and Thursdays,
and then build a final model using all days of the week. At first pass, this
seems fine, assuming you do not somehow time travel your simulations.

However, what happens if the returns look terrible on Tuesdays and Thursdays?
Will you trade it anyway? Probably not. The only way this procedure could
really be unbiased is if you gave up and become an accountant when the
out-of-sample data were discouraging.
Instead, what is likely to happen is that you try again with a different 
strategy until Tuesdays and Thursdays look good. 
You have not prevented overfitting, you merely _slowed it down_.

Put another way, testing on this supposedly out-of-sample data is a statistical
test. You perform it with a fixed rate of type I errors. 
So for example, if you are testing with a 5 percent type I rate,
it means you might rightly reject 19 crappy strategies based on the 
out-of-sample data and mistakenly pass one to live trading. 
Whether this will lead to a profitable out-of-sample experience unfortunately
depends on the unknown background rate of profitable strategies, at least in
this toy example. 

So I say there is no 'out-of-sample', there is only 'in-sample', the data you
have today, and 'trading-real-money'.

## Suboptimal Models

The other kind of overfitting is the classical overfit problem: If you want
to describe the relationship between some observed features and a response,
and you have a sample of size $n$, you could build a polynomial of degree
$n-1$, but it probably will not perform well on new data. A linear
or maybe a quadratic fit will probably have better predictive ability, 
though of course it depends on the underlying reality.

This kind of overfitting applies to quantitative trading strategies in a subtle
way. Consider, for example, the classical portfolio optimization problem
solved by Markowitz. In this problem you are selecting a portfolio weight
for every one of $n$ assets. Without constraints, this is like fitting $n$
points with an $n-1$ degree polynomial! 

Common practice supports the conclusions of this thought experiment: 
you will never find anyone performing portfolio optimization with 
hundreds of free variables.

Unfortunately there is no obvious way to achieve the analogue of the simple
linear fit in portfolio optimization. I mean there is the "1 over N" 
allocation, but it has serious limitations, especially in a framework
that allows shorting. What you will find are lots of heuristics 
for achieving some kind of simplification of the class of models. 
It feels wrong to have to choose among them, as you would prefer to let the 
data speak for themselves. As it was put to me, "a perfectly rational
agent should not be harmed by the addition of options," by which the
speaker meant that adding more stocks to the eligible universe should not
cause a decrease in performance. The answer to this puzzle is that
there are no perfectly rational agents in systematic trading.

## Parting Words

In conclusion, you have my sympathies, but you probably have to write your
own backtesting infrastructure. There is only one open source variant, and 
you will likely decide it is not fast enough or otherwise suitable, and
you will write your own. I hope you have some appreciation of the different
kinds of bugs you may run into, but I do not want to give the impression
that I have catalogued them all. There are new backtester bugs being created
everyday. I apologize for not giving you some magic bullet for
detecting broken backtests, but if you rely on the Baye's Rule argument
I made earlier, and suspect that _all_ backtests are broken, you will not
go too far wrong. 

I do believe that a good way of finding problems with your backtesting
code is to use it a lot. And Machine Learning techniques which do this
via automated search are also very good at finding errors.

At the end of the day, though, making a good systematic strategy is not
only a software engineering challenge. You will need to use your head,
and you will need a lot of luck. I wish you all good luck.

