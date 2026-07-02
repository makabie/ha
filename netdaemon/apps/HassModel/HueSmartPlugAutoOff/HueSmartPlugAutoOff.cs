using System.Globalization;
using NetDaemon.Extensions.Scheduler;

namespace HassModel;

/// <summary>
///     Turns light.hue_smart_plug off again a configurable delay after it was turned on.
///     Controlled via the Home Assistant helpers input_boolean.hue_smart_plug_autooff_enabled
///     (global on/off) and input_number.hue_smart_plug_autooff_minutes (delay in minutes).
/// </summary>
[NetDaemonApp]
public class HueSmartPlugAutoOff
{
    public HueSmartPlugAutoOff(IHaContext ha, INetDaemonScheduler scheduler, ILogger<HueSmartPlugAutoOff> logger)
    {
        var plug = ha.Entity("light.hue_smart_plug");
        var enabled = ha.Entity("input_boolean.hue_smart_plug_autooff_enabled");
        var delayMinutes = ha.Entity("input_number.hue_smart_plug_autooff_minutes");

        IDisposable? pendingTurnOff = null;

        plug.StateChanges()
            .Where(e => e.New?.State == "on")
            .Subscribe(_ =>
            {
                pendingTurnOff?.Dispose();

                if (enabled.State != "on")
                    return;
                NumberStyles styles = NumberStyles.Number | NumberStyles.AllowDecimalPoint;
                var minutes = double.TryParse(delayMinutes.State, styles, CultureInfo.InvariantCulture ,out var parsed) ? parsed : 10;
                logger.LogInformation("HueSmartPlug turned on, scheduling auto-off in {Minutes} min", minutes);
                pendingTurnOff = scheduler.RunIn(TimeSpan.FromMinutes(minutes), () => plug.CallService("turn_off"));
            });

        plug.StateChanges()
            .Where(e => e.New?.State == "off")
            .Subscribe(_ => pendingTurnOff?.Dispose());

        enabled.StateChanges()
            .Where(e => e.New?.State == "off")
            .Subscribe(_ => pendingTurnOff?.Dispose());
    }
}
