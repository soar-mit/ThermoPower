within ThermoPower.customModel.Functions;

function ZukauskasInLineCoeffs
  "Zukauskas in-line tube bank correlation coefficients, from Incropera Fundamentals of heat and mass transfer"
  input Real Re "Reynolds number";
  output Real c "Leading coefficient";
  output Real m "Reynolds exponent";
algorithm
  c := noEvent(
         if Re < 100   then 0.8
         else if Re < 1000  then 0.683    // Single cylinder approx.
         else if Re < 2e5   then 0.27
         else                    0.021);
  m := noEvent(
         if Re < 100   then 0.4
         else if Re < 1000  then 0.466    // single cylinder approx.
         else if Re < 2e5   then 0.63
         else                    0.84);
  annotation (Documentation(info="<html>
<p>Returns (C, m) for Zukauskas in-line tube bank correlation
</html>"));
end ZukauskasInLineCoeffs;
