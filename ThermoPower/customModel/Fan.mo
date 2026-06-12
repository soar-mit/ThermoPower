within ThermoPower.customModel;

model Fan
  "Centrifugal fan with prescribed rotational speed (analogous to Water.Pump)"
  
  extends ThermoPower.customModel.MyFanBase;

  parameter Boolean use_in_n = false
    "= true to use the in_n connector, false to use n_const"
    annotation(Dialog(group = "External inputs"), choices(checkBox = true));
  parameter NonSI.AngularVelocity_rpm n_const = n0
    "Fixed rotational speed when use_in_n = false"
    annotation(Dialog(group = "External inputs", enable = not use_in_n));

  Modelica.Blocks.Interfaces.RealInput in_n if use_in_n
    "Rotational speed [rpm]" annotation(
    Placement(transformation(
      origin = {-26, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));

protected
  Modelica.Blocks.Interfaces.RealInput in_n_internal
    "Internal connector for rotational speed";

equation
  // -- Speed selection --
  connect(in_n, in_n_internal);
  if not use_in_n then
    in_n_internal = n_const;
  end if;
  n = in_n_internal;

  annotation(
    Icon(graphics = {
      Text(extent = {{-58, 94}, {-22, 64}},
           textColor = {0, 0, 127},
           textString = "n")
    }),
    Diagram(graphics),
    Documentation(info = "<html>
<p> This model extends ThermoPower.customModel.MyFanBase to simulate pump-like H-Q behavior.
Only use for low Dp (blower or fan like reactor primary system) conditions, not as turbomachinery.
<p><b> Important: The base fan model does not consider enthalpy rise.
</html>"));
end Fan;