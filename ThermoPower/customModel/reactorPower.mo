within ThermoPower.customModel;

model reactorPower "Point Kinetics Equations with 6 delayed neutron groups and temperature feedback"
  // ============================================================
  //  Power parameters
  // ============================================================
  parameter SI.Power P0 "Nominal (initial) thermal power [W]";
  parameter Boolean usePKE = false "Enable point kinetics";
  // ============================================================
  //  Neutron kinetics parameters
  // ============================================================
  parameter Real Lambda = 4e-4 "Prompt neutron generation time [s]" annotation(
    Dialog(enable = usePKE));
  parameter Real beta_total = 0.0065 "Total delayed neutron fraction" annotation(
    Dialog(enable = usePKE));
  parameter Real beta[6] = {0.000215, 0.001424, 0.001274, 0.002568, 0.000748, 0.000273} "Delayed neutron fractions per group" annotation(
    Dialog(enable = usePKE));
  parameter Real lambda[6] = {0.0124, 0.0305, 0.111, 0.301, 1.14, 3.01} "Delayed neutron precursor decay constants [1/s]" annotation(
    Dialog(enable = usePKE));
  // ============================================================
  //  Temperature feedback parameters
  // ============================================================
  parameter Real alpha_f = -3e-5 "Fuel temperature reactivity coefficient [dk/k/K]" annotation(
    Dialog(enable = usePKE));
  parameter Real alpha_c = -1e-5 "Coolant temperature reactivity coefficient [dk/k/K]" annotation(
    Dialog(enable = usePKE));
  parameter SI.Temperature Tf0 "Reference fuel temperature [K]" annotation(
    Dialog(enable = usePKE));
  parameter SI.Temperature Tc0 "Reference coolant temperature [K]" annotation(
    Dialog(enable = usePKE));
  // ============================================================
  //  Initialisation
  // ============================================================
  parameter Choices.Init.Options initOpt = system.initOpt "Initialisation option" annotation(
    Dialog(tab = "Initialisation"));
  // ============================================================
  //  Variables
  // ============================================================
  Real n(start = 1) "Relative neutron density (n/n0) [-]";
  Real C[6](start = {beta[i]/(Lambda*lambda[i]) for i in 1:6}) "Delayed neutron precursor concentrations (relative)";
  SI.Power P "Absolute thermal power [W]";
  Real rho "Total reactivity [dk/k]";
  Real rho_feedback "Temperature feedback reactivity [dk/k]";
  Real rho_ext_internal "Internal copy of external reactivity";
  outer ThermoPower.System system "System wide properties";
  // ============================================================
  //  Connectors - Inputs
  // ============================================================
  Modelica.Blocks.Interfaces.RealInput rho_ext if usePKE "External reactivity input [dk/k]" annotation(
    Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-100, 0})));
  Modelica.Blocks.Interfaces.RealInput Tf if usePKE "Fuel temperature input [K]" annotation(
    Placement(transformation(origin = {0, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {0, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Interfaces.RealInput Tc if usePKE "Coolant temperature input [K]" annotation(
    Placement(transformation(origin = {0, 100}, extent = {{-10, 10}, {10, -10}}, rotation = -90), iconTransformation(origin = {0, 98}, extent = {{-10, 10}, {10, -10}}, rotation = -90)));
  // ============================================================
  //  Connectors - Outputs
  // ============================================================
  Modelica.Blocks.Interfaces.RealOutput Power "Absolute thermal power output [W]" annotation(
    Placement(transformation(extent = {{90, -10}, {110, 10}})));
protected
  Modelica.Blocks.Interfaces.RealInput Tf_internal;
  Modelica.Blocks.Interfaces.RealInput Tc_internal;
public
equation
// ============================================================
//  Power calculation
// ============================================================
  if usePKE then
    connect(Tf, Tf_internal);
    connect(Tc, Tc_internal);
// reactivity calculation
    rho_ext_internal = rho_ext;
    rho_feedback = alpha_f*(Tf_internal - Tf0) + alpha_c*(Tc_internal - Tc0);
    rho = rho_ext_internal + rho_feedback;
// PKE calculation
    der(n) = (rho - beta_total)/Lambda*n + sum(lambda[i]*C[i] for i in 1:6);
    for i in 1:6 loop
      der(C[i]) = (beta[i]/Lambda)*n - lambda[i]*C[i];
    end for;
  else
// constant power
    rho_ext_internal = 0;
    rho_feedback = 0;
    rho = 0;
    Tf_internal = 0;
    Tc_internal = 0;
    n = 1;
    for i in 1:6 loop
      C[i] = beta[i]/(Lambda*lambda[i]);
    end for;
  end if;
// ============================================================
//  Power output
// ============================================================
  P = n*P0;
  Power = P;
// ============================================================
//  Initial conditions
// ============================================================
initial equation
  der(n) = 0;
  for i in 1:6 loop
    C[i] = beta[i]/(Lambda*lambda[i]);
  end for;
  annotation(
    Icon(graphics = {Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-80, 80}, {80, -80}}), Text(textColor = {0, 0, 255}, extent = {{-60, 40}, {60, -40}}, textString = "Power"), Text(origin = {-28, -4}, textColor = {191, 95, 0}, extent = {{-100, -80}, {100, -110}}, textString = "Tf"), Text(origin = {-28, 194}, textColor = {191, 95, 0}, extent = {{-100, -80}, {100, -110}}, textString = "Tc"), Text(origin = {-156, 136}, textColor = {191, 95, 0}, extent = {{-100, -80}, {100, -110}}, textString = "rho_ext")}),
    Documentation(info = "<HTML>
<p>Point Kinetics Equations (PKE) model with 6 delayed neutron groups.</p>

<p><b>Features:</b></p>
<ul>
<li>6-group delayed neutron precursor equations</li>
<li>External reactivity input via RealInput (can be 0)</li>
<li>Optional fuel/coolant temperature feedback:
  rho_fb = alpha_f*(Tf - Tf0) + alpha_c*(Tc - Tc0)</li>
<li>Absolute (W) and relative power outputs</li>
</ul>

<p><b>Connectors:</b></p>
<ul>
<li><tt>rho_ext</tt>: external reactivity [dk/k]</li>
<li><tt>Tf</tt>: fuel temperature [K] (conditional)</li>
<li><tt>Tc</tt>: coolant temperature [K] (conditional)</li>
<li><tt>Power</tt>: absolute thermal power [W]</li>
<li><tt>relPower</tt>: relative power [-]</li>
</ul>
</HTML>"),
    experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.002),
    Diagram(graphics));
end reactorPower;