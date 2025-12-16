import argparse

from model import FFN


def main():
    parser = argparse.ArgumentParser(description="KDB-DB-ML CLI")

    parser.add_argument(
        "--input-dim",
        type=int,
        required=True,
    )
    parser.add_argument(
        "--output-dim",
        type=int,
        required=True,
    )
    parser.add_argument(
        "--hidden-dims",
        type=int,
        nargs="*",
        default=[],
        help="List of hidden layer dimensions",
    )
    parser.add_argument(
        "--output-path",
        type=str,
        required=False,
        help="Path to save the created model (onnx)",
    )
    args = parser.parse_args()

    print("Creating model with the following parameters:")
    print(f"Input Dimension: {args.input_dim}")
    print(f"Output Dimension: {args.output_dim}")
    print(f"Hidden Dimensions: {args.hidden_dims}")

    model = FFN(
        input_dim=args.input_dim,
        output_dim=args.output_dim,
        hidden_dims=args.hidden_dims if args.hidden_dims else None,
    )

    print("Model created successfully.")
    if args.output_path:
        import torch

        dummy_input = torch.randn(1, args.input_dim)
        torch.onnx.export(
            model,
            dummy_input,  # type: ignore
            args.output_path,
            input_names=["input"],
            output_names=["output"],
            dynamic_axes={"input": {0: "batch_size"}, "output": {0: "batch_size"}},
            external_data=False,
        )
        print(f"Model saved to {args.output_path}")


if __name__ == "__main__":
    main()
