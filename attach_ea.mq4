// attach_ea.mq4
void OnStart()
{
// Open chart and attach EA
long chartId = ChartOpen("EURUSD", PERIOD_M1);
ChartApplyTemplate(chartId, "Default.tpl");

// Attach EA to chart
if(!ChartApplyExpert(chartId, "HelloLogger.ex4", 0, true))
{
Print("Failed to attach EA!");
}
else
{
Print("EA attached successfully!");
}

// Close this script
ExpertRemove();
}