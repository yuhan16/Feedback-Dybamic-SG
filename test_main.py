import parameters as pm
import sg_utils as sg


def test():
    # for necessary tests
    a = 1


def main():
    s0 = 0  # first state
    T = 3
    vA, vB, piA, piB = sg.DP(s0, T)
    sg.plot_value(vA, vB, T)
    sg.plot_policy(piA, piB, T)


if __name__ == "__main__":
    main()
    