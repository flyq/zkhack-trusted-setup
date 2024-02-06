use ark_bls12_381::Fr;
use ark_ec::AffineCurve;
use prompt::{puzzle, welcome};
use std::str::FromStr;
use trusted_setup::data::puzzle_data;
use trusted_setup::PUZZLE_DESCRIPTION;

fn main() {
    welcome();
    puzzle(PUZZLE_DESCRIPTION);
    let (_ts1, _ts2) = puzzle_data();

    /* Your solution here! (s in decimal)*/
    // println!("G1 x: {}, y: {}", _ts1[0].x, _ts1[0].y);
    // println!("s*G1 x: {}, y: {}", _ts1[1].x, _ts1[1].y);

    // println!("G2 x: {}, y: {}", _ts2[0].x., _ts2[0].y);
    // println!("s*G2 x: {}, y: {}", _ts2[1].x, _ts2[1].y);

    let s_origin = Fr::from_str("5592216610550884993006174526481245").unwrap();
    let n_1n_2 = Fr::from_str("38452154918091875653578148163112927").unwrap();

    let mut i = 1000u64;
    let mut s;
    loop {
        s = s_origin + n_1n_2 * Fr::from(i);
        if _ts1[0].mul(s) == _ts1[1] && _ts2[0].mul(s) == _ts2[1] {
            println!("s: {}\ni: {}\n", s, i);
            break;
        }
        i += 1;
    }

    assert_eq!(_ts1[0].mul(s), _ts1[1]);
    assert_eq!(_ts2[0].mul(s), _ts2[1]);
}
