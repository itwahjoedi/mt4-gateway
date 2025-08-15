// HelloLogger.mq4
#property strict

int OnInit()
{
Print("HelloLogger EA Started");
return(INIT_SUCCEEDED);
}

void OnTick()
{
static datetime lastPrint = 0;

if(TimeCurrent() - lastPrint >= 60)
{
Print("Hello from EA! Server Time: ", TimeToStr(TimeCurrent(), TIME_SECONDS));
lastPrint = TimeCurrent();
}
}

void OnDeinit(const int reason)
{
Print("HelloLogger EA Stopped. Reason: ", reason);
}