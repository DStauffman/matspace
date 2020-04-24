Algorithm:

For a rotation about x, y or z (axis 1, 2 or 3 respectively), then:

.. math::
    Tx = \begin{bmatrix}
      1 & 0 & 0 \\
      0 & cos(\theta) & sin(\theta) \\
      0 & -sin(\theta) & cos(\theta)
      \end{bmatrix}

.. math::
    Ty = \begin{bmatrix}
      cos(\theta) & 0 & -sin(\theta) \\
      0 & 1 & 0 \\
      sin(\theta) & 0 & cos(\theta)
      \end{bmatrix}

.. math::
    Tz = \begin{bmatrix}
      cos(\theta) & sin(\theta) & 0 \\
      -sin(\theta) & cos(\theta) & 0 \\
      0 & 0 & 1
      \end{bmatrix}

Test theory:

For :math:`\theta = 30 \deg`; then :math:`cos(\theta)=\frac{\sqrt{3}}{2}` and :math:`sin(\theta)=\frac{1}{2}`, which implies:

.. math::
    Tx = \begin{bmatrix}
      1 & 0 & 0 \\
      0 & \frac{\sqrt{3}}{2} & \frac{1}{2} \\
      0 & -\frac{1}{2} & \frac{\sqrt{3}}{2}
      \end{bmatrix}

.. math::
    Ty = \begin{bmatrix}
      \frac{\sqrt{3}}{2} & 0 & -\frac{1}{2} \\
      0 & 1 & 0 \\
      \frac{1}{2} & 0 & \frac{\sqrt{3}}{2}
      \end{bmatrix}

.. math::
    Tz = \begin{bmatrix}
      \frac{\sqrt{3}}{2} & \frac{1}{2} & 0 \\
      -\frac{1}{2} & \frac{\sqrt{3}}{2} & 0 \\
      0 & 0 & 1
      \end{bmatrix}

For :math:`\theta = 135 \deg = \frac{3 \cdot pi}{4} \deg`; then :math:`cos(\theta)=-\frac{\sqrt{2}}{2}` and :math:`sin(\theta)=\frac{\sqrt{2}}{2}`, which implies:

.. math::
    Tx = \begin{bmatrix}
      1 & 0 & 0 \\
      0 & -\frac{\sqrt{2}}{2} & \frac{\sqrt{2}}{2} \\
      0 & -\frac{\sqrt{2}}{2} & -\frac{\sqrt{2}}{2}
      \end{bmatrix}

.. math::
    Ty = \begin{bmatrix}
      -\frac{\sqrt{2}}{2} & 0 & -\frac{\sqrt{2}}{2} \\
      0 & 1 & 0 \\
      \frac{\sqrt{2}}{2} & 0 & -\frac{\sqrt{2}}{2}
      \end{bmatrix}

.. math::
    Tz = \begin{bmatrix}
      -\frac{\sqrt{2}}{2} & \frac{\sqrt{2}}{2} & 0 \\
      -\frac{\sqrt{2}}{2} & -\frac{\sqrt{2}}{2} & 0 \\
      0 & 0 & 1
      \end{bmatrix}