within ThermoPower.customModel.Models;

model Grid_v
  parameter SI.Power Pgrid "Total nominal power installed on the grid";
//  final parameter SI.Power Poff(fixed = false) "Offset to guarantee f = fnom at initialization";
  parameter SI.PerUnit droop=0.05 "Grid droop";
  parameter SI.Frequency fnom=system.fnom "Nominal frequency";
  constant Real pi = Modelica.Constants.pi;

  outer System system "System object";

  ThermoPower.Electrical.PowerConnection port annotation (Placement(transformation(extent={{-100,
            -14},{-72,14}}, rotation=0)));

  SI.Frequency f "Grid frequency";
  
  // Added part
  parameter Boolean use_in_pset = false;
  
  parameter SI.Power pset_const "Constant set power"
    annotation(Dialog(enable = not use_in_pset));
  
  Modelica.Blocks.Interfaces.RealInput pset if use_in_pset "Set power [W]" annotation (Placement(
        transformation(
        origin={-26,80},
        extent={{-10,-10},{10,10}},
        rotation=270)));
  protected
  Modelica.Blocks.Interfaces.RealInput in_pset_int
    "Internal connector for pset";
  
equation
  // Added part
  connect(pset, in_pset_int);
  if not use_in_pset then
    in_pset_int = pset_const "pset provided by parameter";
  end if;

  der(port.theta) = 2*pi*f;
  //f = fnom*(1 + droop*(port.P - Poff)/Pgrid);
  f = fnom*(1 + droop*(port.P - in_pset_int)/Pgrid);
initial equation
// These are commented out to avoid over-constrained initialization
//  port.theta = 0 "Initial reference angle for the syncronously connected components";
//  f = fnom "Nominal frequency at initialization - sets Poff";
//  port.P = Poff;
  annotation (Diagram(graphics), Icon(graphics={Line(points={{18,-16},{2,-38}},
          color={0,0,0}),Line(points={{-72,0},{-40,0}}, color={0,0,0}),
          Ellipse(
              extent={{100,-68},{-40,68}},
              lineColor={0,0,0},
              lineThickness=0.5),Line(points={{-40,0},{-6,0},{24,36},{54,50}},
          color={0,0,0}),Line(points={{24,36},{36,-6}}, color={0,0,0}),Line(
          points={{-6,0},{16,-14},{40,-52}}, color={0,0,0}),Line(points={{18,
          -14},{34,-6},{70,-22}}, color={0,0,0}),Line(points={{68,18},{36,-4},
          {36,-4}}, color={0,0,0}),Ellipse(
              extent={{-8,2},{-2,-4}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),Ellipse(
              extent={{20,38},{26,32}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),Ellipse(
              extent={{52,54},{58,48}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),Ellipse(
              extent={{14,-12},{20,-18}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),Ellipse(
              extent={{66,22},{72,16}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),Ellipse(
              extent={{32,-2},{38,-8}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),Ellipse(
              extent={{38,-50},{44,-56}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),Ellipse(
              extent={{66,-18},{72,-24}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),Ellipse(
              extent={{0,-34},{6,-40}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid)}),
    Documentation(revisions="<html>
<ul>
<li><i>21 Feb 2019</i>
  by <a href=\"mailto:francesco.casella@polimi.it\">Francesco
Casella</a>:<br>
     Rewrote from scratch.</li>
</ul>
</html>", info="<html>
<p>In this modified grid model, input power can be given as either constant or external signal.</p>
<p>Initial equations are commented out to avoid over-constrained initialization problem.<p>
</html>"),
  experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.002));

end Grid_v;