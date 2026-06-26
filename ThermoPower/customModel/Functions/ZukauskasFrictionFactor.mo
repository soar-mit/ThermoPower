within ThermoPower.customModel.Functions;

function ZukauskasFrictionFactor
  "Zukauskas friction factor for cross-flow over in-line tube bundles"
  input Real Re "Reynolds number";
  input Real pt_OD "Pitch to diameter ratio";
  output Real f "Friction factor (per tube row)";
protected
  Real iRe;
algorithm
  iRe := 1/Re;
  assert(pt_OD == 1.25 or pt_OD == 1.5 or pt_OD == 2.0,
    "ZukauskasFrictionFactor: pt_OD must be 1.25, 1.5, or 2.0, but got " + String(pt_OD), AssertionLevel.error);
  f := noEvent(
    if pt_OD == 1.25 then
      if Re < 2000 then
        0.272 + 0.207e3*iRe + 0.102e3*iRe^2 - 0.286e3*iRe^3
      else
        0.267 + 0.249e4*iRe - 0.927e7*iRe^2 + 0.1e11*iRe^3
    elseif pt_OD == 1.5 then
      if Re < 2000 then
        0.263 + 0.867e2*iRe - 0.202*iRe^2
      else
        0.235 + 0.197e4*iRe - 0.124e8*iRe^2 + 0.312e11*iRe^3 - 0.274e14*iRe^4
    elseif pt_OD == 2.0 then
      if Re < 800 then
        0.188 + 0.566e2*iRe - 0.646e3*iRe^2 + 0.601e4*iRe^3 - 0.183e5*iRe^4
      else
        0.247 - 0.595*iRe + 0.15*iRe^2 - 0.137*iRe^3 + 0.396*iRe^4
     else 0);
             
  annotation(Documentation(info="<html>
<p>Polynomial fit from https://www.thermopedia.com/content/1211/, Heat exhanger design handbook
</html>"));
end ZukauskasFrictionFactor;
