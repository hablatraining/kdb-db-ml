import torch
from torch import nn


class FFN(nn.Module):
    def __init__(
        self, input_dim: int, output_dim: int, hidden_dims: list[int] | None = None
    ):
        super().__init__()

        self.layer = nn.Sequential()
        dims = [input_dim, *(hidden_dims or []), output_dim]

        for left, right in zip(dims[:-1], dims[1:]):
            self.layer.append(nn.Linear(left, right))
            self.layer.append(nn.ReLU())

        self.layer = self.layer[:-1]

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.layer(x)
